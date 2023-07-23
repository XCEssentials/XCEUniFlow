/*
 
 MIT License
 
 Copyright (c) 2016 Maxim Khatskevich (maxim@khatskevi.ch)
 
 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in all
 copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 SOFTWARE.
 
 */

import Foundation
import Combine
import XCEPipeline

//---

public
final
class Dispatcher: ObservableObject
{
    let executionQueue: DispatchQueue
    
    private
    var _storage: Storage
    
    var storage: Storage
    {
        get
        {
            if
                activeTransaction == nil
            {
                return executionQueue.sync {
                    _storage
                }
            }
            else
            {
                /// NOTE: we are in transaction and already must be
                /// on correct queue
                return _storage
            }
        }
    }
    
    private
    var activeTransaction: Transaction?
    
    private
    var internalBindings: [String: [AnyCancellable]] = [:]
    
    fileprivate
    let _accessLog = PassthroughSubject<AccessReport, Never>()
    
    public
    var accessLog: AnyPublisher<AccessReport, Never>
    {
        _accessLog.eraseToAnyPublisher()
    }
    
    fileprivate
    let _status = CurrentValueSubject<[FeatureStatus], Never>([])
    
    public
    var status: AnyPublisher<[FeatureStatus], Never>
    {
        _status.eraseToAnyPublisher()
    }
    
    private
    var statusSubscription: AnyCancellable?
    
    fileprivate
    let _internalBindingsStatusLog = PassthroughSubject<InternalBinding.Status, Never>()
    
    public
    var internalBindingsStatusLog: AnyPublisher<InternalBinding.Status, Never>
    {
        _internalBindingsStatusLog.eraseToAnyPublisher()
    }
    
    //---
    
    /// Initializes dispatcher.
    ///
    /// - Parameters:
    ///     - `storage`: underslaying storage for features, empty by default;
    ///     - `executionQueue`: the queue for read/write operations to storage.
    public
    init(
        with storage: Storage = Storage(),
        executionQueue: DispatchQueue? = nil
    ) {
        let executionQueue = executionQueue ?? .init(
            label: "com.xcessentials.Dispatcher.\(UUID().uuidString)",
            attributes: .concurrent
        )
        
        //---
        
        self.executionQueue = executionQueue
        self._storage = storage
        
        //---
        
        self.statusSubscription = accessLog
            .onProcessed
            .statusReport
            .sink { [weak self] in
                self?._status.send($0)
            }
    }
}

// MARK: - Nested types

extension Dispatcher
{
    public
    struct AccessReport
    {
        public
        let timestamp = Date()
        
        /// Outcome of the access event (success/failure).
        public
        let outcome: Result<Storage.History, Error>
        
        /// Snapshot of the storage at the time of the event.
        public
        let storage: Storage
        
        /// Origin of the event.
        public
        let origin: AccessOrigin
    }
    
    public
    struct AccessOrigin
    {
        public
        let file: String
        
        public
        let function: String
            
        public
        let line: Int
    }
    
    public
    enum AccessError: Error
    {
        case noActiveTransaction
        
        case anotherTransactionIsInProgress(
            anotherTransaction: AccessOrigin
        )
        
        case internalInconsistencyDetected(
            anotherTransaction: AccessOrigin
        )
        
        case failureDuringAccess(
            line: Int,
            cause: Error
        )
    }
    
    fileprivate
    typealias Transaction = (
        origin: AccessOrigin,
        recoverySnapshot: Storage
    )
    
    public
    struct ProcessedActionReport
    {
        public
        let timestamp: Date
        
        public
        let mutations: Storage.History
        
        /// Snapshot of the storage at the time of the event
        /// (including the mutations listed above).
        public
        let storage: Storage
        
        /// Origin of the event.
        public
        let origin: AccessOrigin
    }
    
    public
    struct RejectedActionReport: Error
    {
        public
        let timestamp: Date
        
        public
        let reason: Error
        
        /// Snapshot of the storage at the time of the event
        /// (no mutations were applied as result of this event).
        public
        let storage: Storage
        
        /// Origin of the event.
        public
        let origin: AccessOrigin
    }
}

// MARK: - Access data

public
extension Dispatcher
{
    var allStates: [FeatureStateBase]
    {
        storage.allStates
    }
    
    var allFeatures: [Feature.Type]
    {
        storage.allFeatures
    }
    
    func fetchState(
        forFeature featureType: Feature.Type
    ) throws -> FeatureStateBase {
        
        try storage.fetchState(forFeature: featureType)
    }
    
    func fetchState<S: FeatureState>(
        ofType _: S.Type = S.self
    ) throws -> S {
        
        try storage.fetchState(ofType: S.self)
    }
    
    func on<T: MutationDecriptor>( _: T.Type) -> AnyPublisher<T, Never>
    {
        accessLog.onProcessed.perEachMutation.as(T.self)
    }
}

//internal
extension Dispatcher
{
    @discardableResult
    func transact<T>(
        scope: String = #file,
        context: String = #function,
        location: Int = #line,
        _ handler: () throws -> T
    ) -> Result<T, Error> {

        var report: AccessReport!
        
        /// ‼️ NOTE: use `barrier` for exclusive access during whole transaction
        let result = executionQueue.sync(flags: .barrier) {
            
            try! (scope, context, location)
                ./ startTransaction(scope:context:location:)

            //---

            do
            {
                let output = try handler()
                
                report = try! (scope, context, location)
                    ./ commitTransaction(scope:context:location:)
                
                //---

                return output
                    ./ Result<T, Error>.success(_:)
            }
            catch
            {
                report = try! (scope, context, location, error)
                    ./ rejectTransaction(scope:context:location:reason:)
                
                return error
                    ./ Result<T, Error>.failure(_:)
            }
        }
        
        //---
        
        switch report.outcome
        {
            case .success(let mutationsToReport):
                installInternalBindings(
                    basedOn: mutationsToReport
                )
                
                _accessLog.send(report)
                
                uninstallInternalBindings(
                    basedOn: mutationsToReport
                )
                
            case .failure:
                _accessLog.send(report)
        }
        
        //---
        
        return result
    }
    
    func startTransaction(
        scope s: String = #file,
        context c: String = #function,
        location l: Int = #line
    ) throws {
        
        guard
            activeTransaction == nil
        else
        {
            throw AccessError.anotherTransactionIsInProgress(
                anotherTransaction: activeTransaction!.origin
            )
        }
        
        //---
        
        activeTransaction = (
            .init(file: s, function: c, line: l),
            _storage
        )
    }
    
    func commitTransaction(
        scope s: String = #file,
        context c: String = #function,
        location l: Int = #line
    ) throws -> AccessReport {
        
        guard
            let tr = self.activeTransaction
        else
        {
            throw AccessError.noActiveTransaction
        }
        
        guard
            tr.recoverySnapshot.lastHistoryResetId == storage.lastHistoryResetId
        else
        {
            throw AccessError.internalInconsistencyDetected(
                anotherTransaction: tr.origin
            )
        }
        
        //---
        
        let mutationsToReport = _storage.resetHistory()
        activeTransaction = nil
        
        //---
        
        return .init(
            outcome: .success(
                mutationsToReport
            ),
            storage: _storage,
            origin: tr.origin
        )
    }
    
    func rejectTransaction(
        scope s: String = #file,
        context c: String = #function,
        location l: Int = #line,
        reason: Error
    ) throws -> AccessReport {
        
        guard
            let tr = self.activeTransaction
        else
        {
            throw AccessError.noActiveTransaction
        }
        
        //---
        
        _storage = tr.recoverySnapshot
        self.activeTransaction = nil
        
        //---
        
        return .init(
            outcome: .failure(
                reason
            ),
            storage: _storage,
            origin: tr.origin
        )
    }
    
    
    
    func access(
        scope s: String,
        context c: String,
        location l: Int,
        _ handler: (inout Storage) throws -> Void
    ) throws {
        
        guard
            self.activeTransaction != nil
        else
        {
            throw AccessError.noActiveTransaction
        }
        
        //---

        do
        {
            try handler(&_storage)
        }
        catch
        {
            throw AccessError.failureDuringAccess(
                line: l,
                cause: error
            )
        }
    }
    
    func resetStorage(
        scope s: String = #file,
        context c: String = #function,
        location l: Int = #line
    ) {
        
        try! startTransaction(
            scope: s,
            context: c,
            location: l
        )
        
        //---
        
        try! access(scope: s, context: c, location: l) {
           
            try! $0.removeAll()
        }
        
        //---
        
        _ = try! commitTransaction(
            scope: s,
            context: c,
            location: l
        )
    }
}

// MARK: - Internal bindings management

private
extension Dispatcher
{
    /// This will install bindings for newly initialized keys.
    func installInternalBindings(
        basedOn reports: Storage.History
    ) {
        reports
            .compactMap {
                
                report -> Feature.Type? in
                
                //---
                
                switch report.operation
                {
                    case .initialization(let newState):
                        return type(of: newState).feature
                        
                    default:
                        return nil
                }
            }
            .compactMap {
                $0 as? InternalObserver.Type
            }
            .map {(
                observerType: $0,
                tokens: $0.bindings.map { $0.construct(with: self) }
            )}
            .filter {
                !$0.tokens.isEmpty
            }
            .forEach {
                
                self.internalBindings[$0.observerType.name] = $0.tokens
            }
    }
    
    /// This will uninstall bindings for recently deinitialized keys.
    func uninstallInternalBindings(
        basedOn reports: Storage.History
    ) {
        reports
            .compactMap {
                
                report -> Feature.Type? in
                
                //---
                
                switch report.operation
                {
                    case .deinitialization(let oldState):
                        return type(of: oldState).feature
                        
                    default:
                        return nil
                }
            }
            .forEach {
                
                self.internalBindings.removeValue(forKey: $0.name)
            }
    }
}

// MARK: - Bindings

/// Binding that is defined on type level in a feature and
/// operates within given storage.
public
struct InternalBinding
{
    public
    enum Status
    {
        case activated(InternalBinding)
        
        /// After passing through `when` (and `given`,
        /// if present) claus(es), right before `then`.
        case triggered(InternalBinding, input: Any, output: Any)
        
        /// After executing `then` clause.
        case executed(InternalBinding, input: Any)
        
        case cancelled(InternalBinding)
    }
    
    public
    let description: String
    
    public
    let scope: String
    
    public
    let source: Feature.Type
    
    public
    let location: Int
    
    //---
    
    private
    let body: (Dispatcher, Self) -> AnyPublisher<Void, Never>
    
    //---
    
    //internal
    func construct(with dispatcher: Dispatcher) -> AnyCancellable
    {
        body(dispatcher, self).sink(receiveCompletion: { _ in }, receiveValue: { })
    }
    
    //internal
    init<S: Feature, W: Publisher, G>(
        source: S.Type,
        description: String,
        scope: String,
        location: Int,
        when: @escaping (AnyPublisher<Dispatcher.AccessReport, Never>) -> W,
        given: @escaping (Dispatcher, W.Output) throws -> G?,
        then: @escaping (Dispatcher, G) -> Void
    ) where W.Failure == Never {
        
        self.source = S.self
        self.description = description
        self.scope = scope
        self.location = location
        
        self.body = { dispatcher, binding in
            
            return when(dispatcher.accessLog)
                .compactMap { [weak dispatcher] mutation in

                    guard
                        let dispatcher = dispatcher,
                        let givenOutput = try? given(dispatcher, mutation)
                    else
                    {
                        return nil
                    }

                    //---

                    dispatcher
                        ._internalBindingsStatusLog
                        .send(
                            .triggered(
                                binding,
                                input: mutation,
                                output: givenOutput
                            )
                        )
                    
                    return givenOutput
                }
                .compactMap { [weak dispatcher] (givenOutput: G) -> Void? in
                    
                    guard let dispatcher = dispatcher else { return nil }

                    //---

                    return then(dispatcher, givenOutput) // map into `Void` to erase type info
                }
                .handleEvents(
                    receiveSubscription: { [weak dispatcher] _ in

                        dispatcher?
                            ._internalBindingsStatusLog
                            .send(
                                .activated(binding)
                            )
                    },
                    receiveOutput: { [weak dispatcher] in

                        dispatcher?
                            ._internalBindingsStatusLog
                            .send(
                                .executed(binding, input: $0)
                            )
                    },
                    receiveCancel: { [weak dispatcher] in

                        dispatcher?
                            ._internalBindingsStatusLog
                            .send(
                                .cancelled(binding)
                            )
                    }
                )
                .eraseToAnyPublisher()
        }
    }
}
