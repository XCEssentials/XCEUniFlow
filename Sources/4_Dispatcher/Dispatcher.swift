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
        struct EnvironmentInfo
        {
            public
            let scope: String
            
            public
            let context: String
                
            public
            let location: Int
        }
        
        public
        let timestamp = Date()
        
        public
        let outcome: Outcome
        
        public
        let storage: Storage
        
        public
        let env: EnvironmentInfo
    }
    
    public
    typealias AccessOrigin = (
        scope: String,
        context: String,
        location: Int
        )
    
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
        
        case concurrentChangesDetected(
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
        tmpStorageCopy: Storage,
        lastHistoryResetId: String
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
        let env: AccessReport.EnvironmentInfo
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
        let env: AccessReport.EnvironmentInfo
    }
    
    fileprivate
    struct ExternalSubscription
    {
        private(set)
        weak
        var observer: SomeExternalObserver?
        
        /// Combine tokens of activated bindings (one per each binding)
        let tokens: [AnyCancellable]
        
        init(
            with observer: SomeExternalObserver,
            tokens: [AnyCancellable]
        ) {
            self.observer = observer
            self.tokens = tokens
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
        
        try Thread.isMainThread ?! AccessError.notOnMainThread((s, c, l))
        
        try (activeTransaction == nil) ?! AccessError.anotherTransactionIsInProgress(
            (s, c, l),
            anotherTransaction: activeTransaction!
                .origin
                ./ { ($0.scope, $0.context, $0.location) }
        )
        
        //---
        
        activeTransaction = (
            (s, c, l),
            storage,
            storage.lastHistoryResetId
        )
    }
    
    @discardableResult
    func commitTransaction(
        scope s: String = #file,
        context c: String = #function,
        location l: Int = #line
    ) throws -> Storage.History {
        
        try Thread.isMainThread ?! AccessError.notOnMainThread((s, c, l))
        
        var tr = try self.activeTransaction ?! AccessError.noActiveTransaction((s, c, l))
        
        try (tr.lastHistoryResetId == storage.lastHistoryResetId) ?! AccessError.concurrentChangesDetected(
            (s, c, l),
            anotherTransaction: tr.origin
        )
        
        //---
        
        let mutationsToReport = tr.tmpStorageCopy.resetHistory()
        
        // apply changes to permanent storage
        storage = tr.tmpStorageCopy // NOTE: the history has already been cleared

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
                env: .init(
                    scope: tr.origin.scope,
                    context: tr.origin.context,
                    location: tr.origin.location
                )
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
        
        try Thread.isMainThread ?! AccessError.notOnMainThread((s, c, l))
        
        let tr = try self.activeTransaction ?! AccessError.noActiveTransaction((s, c, l))
        
        //---
        
        _accessLog.send(
            .init(
                outcome: .rejected(
                    reason: reason
                    ),
                storage: storage,
                env: .init(
                    scope: tr.origin.scope,
                    context: tr.origin.context,
                    location: tr.origin.location
                )
            )
        )
        
        //---
        
        self.activeTransaction = nil
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
        
        try Thread.isMainThread ?! AccessError.notOnMainThread((s, c, l))
        
        var tr = try activeTransaction ?! AccessError.noActiveTransaction((s, c, l))
        
        //---

        do
        {
            try handler(&tr.tmpStorageCopy)
        }
        catch
        {
            throw AccessError.failureDuringAccess(
                (s, c, l),
                transaction: tr.origin,
                cause: error
            )
        }
        
        activeTransaction = tr
    }
    
    func fetchState(
        scope s: String = #file,
        context c: String = #function,
        location l: Int = #line,
        forFeature featureType: SomeFeature.Type
    ) throws -> SomeStateBase {
        
        try Thread.isMainThread ?! AccessError.notOnMainThread((s, c, l))
        
        //---
        
        if
            let tr = self.activeTransaction
        {
            return try tr.tmpStorageCopy.fetchState(forFeature: featureType)
        }
        else
        {
            return try storage.fetchState(forFeature: featureType)
        }
    }
    
    func fetchState<S: SomeState>(
        scope s: String = #file,
        context c: String = #function,
        location l: Int = #line,
        ofType _: S.Type = S.self
    ) throws -> S {
        
        try Thread.isMainThread ?! AccessError.notOnMainThread((s, c, l))
        
        //---
        
        if
            let tr = self.activeTransaction
        {
            return try tr.tmpStorageCopy.fetchState(ofType: S.self)
        }
        else
        {
            return try storage.fetchState(ofType: S.self)
        }
    }
    
    func removeAll(
        scope s: String = #file,
        context c: String = #function,
        location l: Int = #line
    ) throws {
        
        try! startTransaction(
            scope: s,
            context: c,
            location: l
        )
        
        //---
        
        try access(scope: s, context: c, location: l) {
           
            try $0.removeAll()
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
    /// Activates `observer` bindings within `self`
    /// and stores binding tokens for as long
    /// as `observer` is in memory, or until `unsubscribe`
    /// for same `observer` is called.
    ///
    /// - Returns: array of Combine tokens (`AnyCancellable`)
    ///     for activated bindings.
    @discardableResult
    public
    func subscribe(_ observer: SomeExternalObserver) -> [AnyCancellable]
    {
        let observerId = ObjectIdentifier(observer)
        
        let newSubscribtion = observer
            .bindings
            .map{ $0.construct(with: self) }
            ./ { ExternalSubscription(with: observer, tokens: $0) }
        
        externalBindings[observerId] = newSubscribtion
        
        return newSubscribtion.tokens
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
    let source: SomeExternalObserver.Type
    
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
    init<S: SomeExternalObserver, W: Publisher, G>(
        source: S,
        description: String,
        scope: String,
        location: Int,
        when: @escaping (AnyPublisher<Dispatcher.AccessReport, Never>) -> W,
        given: @escaping (Dispatcher, W.Output) throws -> G?,
        then: @escaping (S, G, Dispatcher) -> Void
    ) {
        assert(Thread.isMainThread, "Must be on main thread!")
        
        //---
        
        self.source = S.self
        self.description = description
        self.scope = scope
        self.location = location

        self.body = { [weak source] dispatcher, binding in
            
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
                            ._externalBindingsStatusLog
                            .send(
                                .triggered(binding)
                            )
                    }
                )
                .compactMap { [weak dispatcher] (givenOutput: G) -> Void? in

                    guard let dispatcher = dispatcher else { return nil }
                    guard let source = source else { return nil }

                    //---

                    return then(source, givenOutput, dispatcher) // map into `Void` to erase type info
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
                .eraseToAnyPublisher()
        }
    }
}
