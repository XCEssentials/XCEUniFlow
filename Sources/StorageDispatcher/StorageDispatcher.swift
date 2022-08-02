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
class StorageDispatcher
{
    typealias AccessHandler = (inout ByTypeStorage) throws -> Void
    
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
    
    public
    struct Proxy
    {
        let dispatcher: StorageDispatcher
        
        public
        var accessLog: AnyPublisher<AccessReport, Never>
        {
            dispatcher
                ._accessLog
                .eraseToAnyPublisher()
        }
        
        public
        var status: AnyPublisher<[FeatureStatus], Never>
        {
            dispatcher
                ._status
                .eraseToAnyPublisher()
        }
        
        public
        var internalBindingsStatusLog: AnyPublisher<InternalBinding.Status, Never>
        {
            dispatcher
                ._internalBindingsStatusLog
                .eraseToAnyPublisher()
        }
        
        public
        var externalBindingsStatusLog: AnyPublisher<ExternalBinding.Status, Never>
        {
            dispatcher
                ._externalBindingsStatusLog
                .eraseToAnyPublisher()
        }
    }
    
    fileprivate
    typealias Transaction = (
        origin: AccessOrigin,
        tmpStorageCopy: ByTypeStorage,
        lastHistoryResetId: String
    )
    
    fileprivate
    typealias AccessLog = PassthroughSubject<AccessReport, Never>
 
    fileprivate
    typealias Status = CurrentValueSubject<[FeatureStatus], Never>
    
    fileprivate
    struct ExternalSubscription
    {
        typealias Identifier = ObjectIdentifier
        
        let identifier: Identifier
        
        private(set)
        weak
        var observer: SomeExternalObserver?
        
        let bindings: [AnyCancellable]
        
        init(
            with observer: SomeExternalObserver,
            bindings: [AnyCancellable]
        ) {
            // NOTE: 1 sub per observer per dispatcher only!
            self.identifier = Identifier(observer)
            
            self.observer = observer
            self.bindings = bindings
        }
    }
    
    //---
    
    private(set)
    var storage: ByTypeStorage
    
    private
    var activeTransaction: Transaction?
    
    private
    var internalBindings: [String: [AnyCancellable]] = [:]
    
    private
    var externalBindings: [ExternalSubscription.Identifier: ExternalSubscription] = [:]
    
    fileprivate
    let _accessLog = AccessLog()
    
    fileprivate
    let _status = Status([])
    
    private
    var statusSubscription: AnyCancellable?
    
    fileprivate
    let _internalBindingsStatusLog = PassthroughSubject<InternalBinding.Status, Never>()
    
    fileprivate
    let _externalBindingsStatusLog = PassthroughSubject<ExternalBinding.Status, Never>()
    
    public
    var proxy: Proxy
    {
        .init(dispatcher: self)
    }
    
    //---
    
    public
    init(
        with storage: ByTypeStorage = ByTypeStorage()
    ) {
        assert(Thread.isMainThread, "Must be on main thread!")
        
        //---
        
        self.storage = storage
        
        //---
        
        self.statusSubscription = proxy
            .accessLog
            .onProcessed
            .statusReport
            .sink { [weak self] in
                self?._status.send($0)
            }
    }
}

// MARK: - Access data

public
extension StorageDispatcher
{
    var allValues: [SomeStateBase]
    {
        storage.allValues
    }
    
    var allKeys: [SomeStateful.Type]
    {
        storage.allKeys
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
    ) throws -> ByTypeStorage.History {
        
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
        
        cleanupExternalBindings()
        
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
extension StorageDispatcher
{
    func access(
        scope s: String,
        context c: String,
        location l: Int,
        _ handler: AccessHandler
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
    
    func fetch(
        scope s: String = #file,
        context c: String = #function,
        location l: Int = #line,
        valueForKey keyType: SomeStateful.Type
    ) throws -> SomeStateBase {
        
        try Thread.isMainThread ?! AccessError.notOnMainThread((s, c, l))
        
        //---
        
        if
            let tr = self.activeTransaction
        {
            return try tr.tmpStorageCopy.fetch(valueForKey: keyType)
        }
        else
        {
            return try storage.fetch(valueForKey: keyType)
        }
    }
    
    func fetch<V: SomeState>(
        scope s: String = #file,
        context c: String = #function,
        location l: Int = #line,
        valueOfType _: V.Type = V.self
    ) throws -> V {
        
        try Thread.isMainThread ?! AccessError.notOnMainThread((s, c, l))
        
        //---
        
        if
            let tr = self.activeTransaction
        {
            return try tr.tmpStorageCopy.fetch(valueOfType: V.self)
        }
        else
        {
            return try storage.fetch(valueOfType: V.self)
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
extension StorageDispatcher
{
    /// This will install bindings for newly initialized keys.
    func installInternalBindings(
        basedOn reports: ByTypeStorage.History
    ) {
        assert(Thread.isMainThread, "Must be on main thread!")
        
        //---
        
        reports
            .compactMap {
                
                report -> SomeStateful.Type? in
                
                //---
                
                switch report.outcome
                {
                    case .initialization(let newValue):
                        return type(of: newValue).feature
                        
                    default:
                        return nil
                }
            }
            .compactMap {
                $0 as? SomeObservingFeature.Type
            }
            .map {(
                observerType: $0,
                bindings: $0.bindings.map { $0.construct(with: self) }
            )}
            .filter {
                !$0.bindings.isEmpty
            }
            .forEach {
                
                self.internalBindings[$0.observerType.name] = $0.bindings
            }
    }
    
    /// This will uninstall bindings for recently deinitialized keys.
    func uninstallInternalBindings(
        basedOn reports: ByTypeStorage.History
    ) {
        assert(Thread.isMainThread, "Must be on main thread!")
        
        //---
        
        reports
            .compactMap {
                
                report -> SomeStateful.Type? in
                
                //---
                
                switch report.outcome
                {
                    case .deinitialization(let oldValue):
                        return type(of: oldValue).feature
                        
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

extension StorageDispatcher
{
    @discardableResult
    public
    func subscribe(_ observer: SomeExternalObserver) -> [AnyCancellable]
    {
        let newSubscribtion = observer
            .bindings
            .map{ $0.construct(with: self) }
            ./ { ExternalSubscription(with: observer, bindings: $0) }
        
        externalBindings[newSubscribtion.identifier] = newSubscribtion
        
        return newSubscribtion.bindings
    }
    
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
    let source: SomeStateful.Type
    
    public
    let description: String
    
    public
    let scope: String
    
    public
    let location: Int
    
    //---
    
    private
    let body: (StorageDispatcher, Self) -> AnyPublisher<Void, Error>
    
    //---
    
    //internal
    func construct(with dispatcher: StorageDispatcher) -> AnyCancellable
    {
        body(dispatcher, self).sink(receiveCompletion: { _ in }, receiveValue: { })
    }
    
    //internal
    init<S: SomeStateful, W: Publisher, G>(
        source: S.Type,
        description: String,
        scope: String,
        location: Int,
        when: @escaping (AnyPublisher<StorageDispatcher.AccessReport, Never>) -> W,
        given: @escaping (StorageDispatcher, W.Output) throws -> G?,
        then: @escaping (StorageDispatcher, G) -> Void
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
            
            return when(dispatcher.proxy.accessLog)
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
    let body: (StorageDispatcher, Self) -> AnyPublisher<Void, Error>
    
    //---
    
    //internal
    func construct(with dispatcher: StorageDispatcher) -> AnyCancellable
    {
        body(dispatcher, self).sink(receiveCompletion: { _ in }, receiveValue: { })
    }
    
    //internal
    init<S: SomeExternalObserver, W: Publisher, G>(
        source: S,
        description: String,
        scope: String,
        location: Int,
        when: @escaping (AnyPublisher<StorageDispatcher.AccessReport, Never>) -> W,
        given: @escaping (StorageDispatcher, W.Output) throws -> G?,
        then: @escaping (S, G, StorageDispatcher.Proxy) -> Void
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
            
            return when(dispatcher.proxy.accessLog)
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

                    return then(source, givenOutput, dispatcher.proxy) // map into `Void` to erase type info
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
