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
class Dispatcher
{
    private(set)
    var storage: Storage
    
    private
    var activeTransaction: Transaction?
    
    private
    var internalBindings: [String: [AnyCancellable]] = [:]
    
    private
    var externalBindings: [ObjectIdentifier: ExternalSubscription] = [:]
    
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
    
    private
    var externalBindingsSubscription: AnyCancellable?
    
    fileprivate
    let _internalBindingsStatusLog = PassthroughSubject<InternalBinding.Status, Never>()
    
    public
    var internalBindingsStatusLog: AnyPublisher<InternalBinding.Status, Never>
    {
        _internalBindingsStatusLog.eraseToAnyPublisher()
    }
    
    fileprivate
    let _externalBindingsStatusLog = PassthroughSubject<ExternalBinding.Status, Never>()
    
    public
    var externalBindingsStatusLog: AnyPublisher<ExternalBinding.Status, Never>
    {
        _externalBindingsStatusLog.eraseToAnyPublisher()
    }
    
    //---
    
    public
    init(
        with storage: Storage = Storage()
    ) {
        assert(Thread.isMainThread, "Must be on main thread!")
        
        //---
        
        self.storage = storage
        
        //---
        
        self.statusSubscription = accessLog
            .onProcessed
            .statusReport
            .sink { [weak self] in
                self?._status.send($0)
            }
        
        self.externalBindingsSubscription = accessLog
            .onProcessed
            .perEachMutation
            .sink { [weak self] mutation in
                
                guard let dispatcher = self else { return }
                
                //---
                
                dispatcher
                    .externalBindings
                    .values
                    .compactMap {
                        $0.observer
                    }
                    .flatMap {
                        $0.bindings()
                    }
                    .forEach {
                        $0.execute(
                            with: dispatcher,
                            mutation: mutation
                        )
                    }
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
        enum Outcome
        {
            /// Access request has been succesfully processed.
            ///
            /// Any occurred mutations (see payload) have already been applied to the `storage`.
            case processed(
                mutations: Storage.History
            )
            
            /// Access request has been rejected due to an error thrown from access handler.
            ///
            /// NO changes have been applied to the `storage`.
            case rejected(
                reason: Error
            )
        }
        
        public
        let timestamp = Date()
        
        public
        let outcome: Outcome
        
        public
        let storage: Storage
        
        public
        let origin: AccessOrigin
    }
    
    public
    struct AccessOrigin
    {
        public
        let scope: String
        
        public
        let context: String
            
        public
        let location: Int
    }
    
    public
    enum AccessError: Error
    {
        case notOnMainThread(
            AccessOrigin
        )
        
        case noActiveTransaction(
            AccessOrigin
        )
        
        case anotherTransactionIsInProgress(
            AccessOrigin,
            anotherTransaction: AccessOrigin
        )
        
        case internalInconsistencyDetected(
            AccessOrigin,
            anotherTransaction: AccessOrigin
        )
        
        case failureDuringAccess(
            AccessOrigin,
            transaction: AccessOrigin,
            cause: Error
        )
    }
    
    fileprivate
    typealias Transaction = (
        origin: AccessOrigin,
        recoverySnapshot: Storage
    )
    
    public
    struct ProcessedAccessEventReport
    {
        public
        let timestamp: Date
        
        public
        let mutations: Storage.History
        
        public
        let storage: Storage
        
        public
        let origin: AccessOrigin
    }
    
    public
    struct RejectedAccessEventReport
    {
        public
        let timestamp: Date
        
        public
        let reason: Error
        
        public
        let storage: Storage
        
        public
        let origin: AccessOrigin
    }
    
    fileprivate
    struct ExternalSubscription
    {
        private(set)
        weak
        var observer: SomeExternalObserver?
        
        init(
            with observer: SomeExternalObserver
        ) {
            self.observer = observer
        }
    }
}

// MARK: - Access data

public
extension Dispatcher
{
    var allStates: [SomeStateBase]
    {
        storage.allStates
    }
    
    var allFeatures: [SomeFeature.Type]
    {
        storage.allFeatures
    }

    func startTransaction(
        scope s: String = #file,
        context c: String = #function,
        location l: Int = #line
    ) throws {
        
        guard
            Thread.isMainThread
        else
        {
            throw AccessError.notOnMainThread(
                .init(scope: s, context: c, location: l)
            )
        }
        
        guard
            activeTransaction == nil
        else
        {
            throw AccessError.anotherTransactionIsInProgress(
                .init(scope: s, context: c, location: l),
                anotherTransaction: activeTransaction!.origin
            )
        }
        
        //---
        
        activeTransaction = (
            .init(scope: s, context: c, location: l),
            storage
        )
    }
    
    @discardableResult
    func commitTransaction(
        scope s: String = #file,
        context c: String = #function,
        location l: Int = #line
    ) throws -> Storage.History {
        
        guard
            Thread.isMainThread
        else
        {
            throw AccessError.notOnMainThread(
                .init(scope: s, context: c, location: l)
            )
        }
        
        guard
            let tr = self.activeTransaction
        else
        {
            throw AccessError.noActiveTransaction(
                .init(scope: s, context: c, location: l)
            )
        }
        
        guard
            tr.recoverySnapshot.lastHistoryResetId == storage.lastHistoryResetId
        else
        {
            throw AccessError.internalInconsistencyDetected(
                .init(scope: s, context: c, location: l),
                anotherTransaction: tr.origin
            )
        }
        
        //---
        
        let mutationsToReport = storage.resetHistory()
        activeTransaction = nil
        
        //---
        
        cleanupExternalBindings()
        
        installInternalBindings(
            basedOn: mutationsToReport
        )

        _accessLog.send(
            .init(
                outcome: .processed(
                    mutations: mutationsToReport
                ),
                storage: storage,
                origin: tr.origin
            )
        )
        
        uninstallInternalBindings(
            basedOn: mutationsToReport
        )
        
        //---
        
        return mutationsToReport
    }
    
    func rejectTransaction(
        scope s: String = #file,
        context c: String = #function,
        location l: Int = #line,
        reason: Error
    ) throws {
        
        guard
            Thread.isMainThread
        else
        {
            throw AccessError.notOnMainThread(
                .init(scope: s, context: c, location: l)
            )
        }
        
        guard
            let tr = self.activeTransaction
        else
        {
            throw AccessError.noActiveTransaction(
                .init(scope: s, context: c, location: l)
            )
        }
        
        //---
        
        storage = tr.recoverySnapshot
        self.activeTransaction = nil
        
        //---
        
        _accessLog.send(
            .init(
                outcome: .rejected(
                    reason: reason
                    ),
                storage: storage,
                origin: tr.origin
            )
        )
    }
}

//internal
extension Dispatcher
{
    func access(
        scope s: String,
        context c: String,
        location l: Int,
        _ handler: (inout Storage) throws -> Void
    ) throws {
        
        guard
            Thread.isMainThread
        else
        {
            throw AccessError.notOnMainThread(
                .init(scope: s, context: c, location: l)
            )
        }
        
        guard
            let tr = self.activeTransaction
        else
        {
            throw AccessError.noActiveTransaction(
                .init(scope: s, context: c, location: l)
            )
        }
        
        //---

        do
        {
            try handler(&storage)
        }
        catch
        {
            throw AccessError.failureDuringAccess(
                .init(scope: s, context: c, location: l),
                transaction: tr.origin,
                cause: error
            )
        }
    }
    
    func fetchState(
        scope s: String = #file,
        context c: String = #function,
        location l: Int = #line,
        forFeature featureType: SomeFeature.Type
    ) throws -> SomeStateBase {
        
        guard
            Thread.isMainThread
        else
        {
            throw AccessError.notOnMainThread(
                .init(scope: s, context: c, location: l)
            )
        }
        
        //---
        
        return try storage.fetchState(forFeature: featureType)
    }
    
    func fetchState<S: SomeState>(
        scope s: String = #file,
        context c: String = #function,
        location l: Int = #line,
        ofType _: S.Type = S.self
    ) throws -> S {
        
        guard
            Thread.isMainThread
        else
        {
            throw AccessError.notOnMainThread(
                .init(scope: s, context: c, location: l)
            )
        }
        
        //---
        
        return try storage.fetchState(ofType: S.self)
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
        
        try! commitTransaction(
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
        assert(Thread.isMainThread, "Must be on main thread!")
        
        //---
        
        reports
            .compactMap {
                
                report -> SomeFeature.Type? in
                
                //---
                
                switch report.outcome
                {
                    case .initialization(let newState):
                        return type(of: newState).feature
                        
                    default:
                        return nil
                }
            }
            .compactMap {
                $0 as? SomeInternalObserver.Type
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
        assert(Thread.isMainThread, "Must be on main thread!")
        
        //---
        
        reports
            .compactMap {
                
                report -> SomeFeature.Type? in
                
                //---
                
                switch report.outcome
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

// MARK: - External bindings management

extension Dispatcher
{
    /// Registers `observer` for bindings execution
    /// within `self` for as long as `observer` is
    /// in memory, or until `unsubscribe` is called
    /// for same `observer`.
    public
    func subscribe(_ observer: SomeExternalObserver)
    {
        let observerId = ObjectIdentifier(observer)
        externalBindings[observerId] = ExternalSubscription(with: observer)
    }
    
    /// Deactivates `observer` bindings within `self`.
    public
    func unsubscribe(_ observer: SomeExternalObserver)
    {
        let observerId = ObjectIdentifier(observer)
        externalBindings[observerId] = nil
    }
    
    /// Internal method to celanup
    private
    func cleanupExternalBindings()
    {
        externalBindings = externalBindings.filter { $0.value.observer != nil }
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
        case triggered(InternalBinding)
        
        /// After executing `then` clause.
        case executed(InternalBinding)
        
        case failed(InternalBinding, Error)
        
        case cancelled(InternalBinding)
    }

    public
    let source: SomeFeature.Type
    
    public
    let description: String
    
    public
    let scope: String
    
    public
    let location: Int
    
    //---
    
    private
    let body: (Dispatcher, Self) -> AnyPublisher<Void, Error>
    
    //---
    
    //internal
    func construct(with dispatcher: Dispatcher) -> AnyCancellable
    {
        body(dispatcher, self).sink(receiveCompletion: { _ in }, receiveValue: { })
    }
    
    //internal
    init<S: SomeFeature, W: Publisher, G>(
        source: S.Type,
        description: String,
        scope: String,
        location: Int,
        when: @escaping (AnyPublisher<Dispatcher.AccessReport, Never>) -> W,
        given: @escaping (Dispatcher, W.Output) throws -> G?,
        then: @escaping (Dispatcher, G) -> Void
    ) {
        assert(Thread.isMainThread, "Must be on main thread!")
        
        //---
        
        self.source = S.self
        self.description = description
        self.scope = scope
        self.location = location
        
        self.body = { dispatcher, binding in
            
            assert(Thread.isMainThread, "Must be on main thread!")
            
            //---
            
            return when(dispatcher.accessLog)
                .tryCompactMap { [weak dispatcher] in

                    guard let dispatcher = dispatcher else { return nil }

                    //---

                    return try given(dispatcher, $0)
                }
                .handleEvents(
                    receiveOutput: { [weak dispatcher] _ in

                        dispatcher?
                            ._internalBindingsStatusLog
                            .send(
                                .triggered(binding)
                            )
                    }
                )
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
                    receiveOutput: { [weak dispatcher] _ in

                        dispatcher?
                            ._internalBindingsStatusLog
                            .send(
                                .executed(binding)
                            )
                    },
                    receiveCompletion: { [weak dispatcher] in

                        switch $0
                        {
                            case .failure(let error):

                                dispatcher?
                                    ._internalBindingsStatusLog
                                    .send(
                                        .failed(binding, error)
                                    )

                            default:
                                break
                        }
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

/// Binding that is defined on instance level in an external observer and
/// operates in context of a given storage + given observer instance.
public
struct ExternalBinding
{
    public
    enum Status
    {
        case activated(ExternalBinding)
        
        /// After passing through `when` (and `given`,
        /// if present) claus(es), right before `then`.
        case triggered(ExternalBinding)
        
        /// After executing `then` clause.
        case executed(ExternalBinding)
        
        case failed(ExternalBinding, Error)
        
        case cancelled(ExternalBinding)
    }

    public
    let description: String
    
    public
    let scope: String
    
    public
    let context: SomeExternalObserver.Type
    
    public
    let location: Int
    
    //---
    
    private
    let body: (Storage.HistoryElement, Dispatcher, Self) -> Void
    
    //---
    
    //internal
    func execute(with dispatcher: Dispatcher, mutation: Storage.HistoryElement)
    {
        body(mutation, dispatcher, self)
    }
    
    //internal
    init<S: SomeExternalObserver, W: SomeMutationDecriptor, G>(
        description: String,
        scope: String,
        context: S.Type,
        location: Int,
        given: @escaping (Dispatcher, W) throws -> G?,
        then: @escaping (G, Dispatcher) -> Void
    ) {
        assert(Thread.isMainThread, "Must be on main thread!")
        
        //---
        
        self.description = description
        self.scope = scope
        self.context = S.self
        self.location = location

        self.body = { mutation, dispatcher, binding in
            
            assert(Thread.isMainThread, "Must be on main thread!")
            
            //---
            
            Just(mutation)
                .as(W.self)
                .tryCompactMap { [weak dispatcher] in

                    guard let dispatcher = dispatcher else { return nil }

                    //---

                    return try given(dispatcher, $0)
                }
                .handleEvents(
                    receiveOutput: { [weak dispatcher] _ in

                        dispatcher?
                            ._externalBindingsStatusLog
                            .send(
                                .triggered(binding)
                            )
                    }
                )
                .compactMap { [weak dispatcher] (givenOutput: G) -> Void? in

                    guard let dispatcher = dispatcher else { return nil }

                    //---

                    return then(givenOutput, dispatcher) // map into `Void` to erase type info
                }
                .handleEvents(
                    receiveSubscription: { [weak dispatcher] _ in

                        dispatcher?
                            ._externalBindingsStatusLog
                            .send(
                                .activated(binding)
                            )
                    },
                    receiveOutput: { [weak dispatcher] _ in

                        dispatcher?
                            ._externalBindingsStatusLog
                            .send(
                                .executed(binding)
                            )
                    },
                    receiveCompletion: { [weak dispatcher] in

                        switch $0
                        {
                            case .failure(let error):

                                dispatcher?
                                    ._externalBindingsStatusLog
                                    .send(
                                        .failed(binding, error)
                                    )

                            default:
                                break
                        }
                    },
                    receiveCancel: { [weak dispatcher] in

                        dispatcher?
                            ._externalBindingsStatusLog
                            .send(
                                .cancelled(binding)
                            )
                    }
                )
                .executeNow()
        }
    }
}
