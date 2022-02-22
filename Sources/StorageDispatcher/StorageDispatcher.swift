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
    struct StatusProxy
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
        var bindingsInStorageStatusLog: AnyPublisher<BindingInStorage.Status, Never>
        {
            dispatcher
                ._bindingsInStorageStatusLog
                .eraseToAnyPublisher()
        }
        
        public
        var bindingsViewModelStatusLog: AnyPublisher<BindingViewModel.Status, Never>
        {
            dispatcher
                ._bindingsViewModelStatusLog
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
    
    //---
    
    private(set)
    var storage: ByTypeStorage
    
    private
    var activeTransaction: Transaction?
    
    private
    var bindings: [String: [AnyCancellable]] = [:]
    
    fileprivate
    let _accessLog = AccessLog()
    
    fileprivate
    let _status = Status([])
    
    private
    var statusSubscription: AnyCancellable?
    
    fileprivate
    let _bindingsInStorageStatusLog = PassthroughSubject<BindingInStorage.Status, Never>()
    
    fileprivate
    let _bindingsViewModelStatusLog = PassthroughSubject<BindingViewModel.Status, Never>()
    
    public
    var proxy: StatusProxy
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
        
        installBindings(
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
        
        uninstallBindings(
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

// MARK: - Bindings management

private
extension StorageDispatcher
{
    /// This will install bindings for newly initialized keys.
    func installBindings(
        basedOn reports: ByTypeStorage.History
    ) {
        assert(Thread.isMainThread, "Must be on main thread!")
        
        //---
        
        reports
            .compactMap { report -> SomeStateful.Type? in
                
                switch report.outcome
                {
                    case .initialization(let key, _):
                        return key
                        
                    default:
                        return nil
                }
            }
            .compactMap {
                $0 as? SomeWorkflow.Type
            }
            .map {(
                workflow: $0,
                bindings: $0
                    .bindings
                    .map {
                        $0.construct(with: self)
                    }
            )}
            .filter {
                !$0.bindings.isEmpty
            }
            .forEach {
                
                self.bindings[$0.workflow.name] = $0.bindings
            }
    }
    
    /// This will uninstall bindings for recently deinitialized keys.
    func uninstallBindings(
        basedOn reports: ByTypeStorage.History
    ) {
        assert(Thread.isMainThread, "Must be on main thread!")
        
        //---
        
        reports
            .compactMap { report -> SomeStateful.Type? in
                
                switch report.outcome
                {
                    case .deinitialization(let key, _):
                        return key
                        
                    default:
                        return nil
                }
            }
            .forEach {
                
                self.bindings.removeValue(forKey: $0.name)
            }
    }
}

// MARK: - MutationBinding

public
struct BindingInStorage
{
    public
    enum Status
    {
        case activated(BindingInStorage)
        
        /// After passing through `when` (and `given`,
        /// if present) claus(es), right before `then`.
        case triggered(BindingInStorage)
        
        /// After executing `then` clause.
        case executed(BindingInStorage)
        
        case failed(BindingInStorage, Error)
        
        case cancelled(BindingInStorage)
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
                            ._bindingsInStorageStatusLog
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
                            ._bindingsInStorageStatusLog
                            .send(
                                .activated(binding)
                            )
                    },
                    receiveOutput: { [weak dispatcher] _ in

                        dispatcher?
                            ._bindingsInStorageStatusLog
                            .send(
                                .executed(binding)
                            )
                    },
                    receiveCompletion: { [weak dispatcher] in

                        switch $0
                        {
                            case .failure(let error):

                                dispatcher?
                                    ._bindingsInStorageStatusLog
                                    .send(
                                        .failed(binding, error)
                                    )

                            default:
                                break
                        }
                    },
                    receiveCancel: { [weak dispatcher] in

                        dispatcher?
                            ._bindingsInStorageStatusLog
                            .send(
                                .cancelled(binding)
                            )
                    }
                )
                .eraseToAnyPublisher()
        }
    }
}

public
struct BindingViewModel
{
    public
    enum Status
    {
        case activated(BindingViewModel)
        
        /// After passing through `when` (and `given`,
        /// if present) claus(es), right before `then`.
        case triggered(BindingViewModel)
        
        /// After executing `then` clause.
        case executed(BindingViewModel)
        
        case failed(BindingViewModel, Error)
        
        case cancelled(BindingViewModel)
    }

    public
    let source: SomeViewModel.Type
    
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
    init<S: SomeViewModel, W: Publisher, G>(
        source: S,
        description: String,
        scope: String,
        location: Int,
        when: @escaping (AnyPublisher<StorageDispatcher.AccessReport, Never>) -> W,
        given: @escaping (StorageDispatcher, W.Output) throws -> G?,
        then: @escaping (S, G, StorageDispatcher.StatusProxy) -> Void
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
                            ._bindingsViewModelStatusLog
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
                            ._bindingsViewModelStatusLog
                            .send(
                                .activated(binding)
                            )
                    },
                    receiveOutput: { [weak dispatcher] _ in

                        dispatcher?
                            ._bindingsViewModelStatusLog
                            .send(
                                .executed(binding)
                            )
                    },
                    receiveCompletion: { [weak dispatcher] in

                        switch $0
                        {
                            case .failure(let error):

                                dispatcher?
                                    ._bindingsViewModelStatusLog
                                    .send(
                                        .failed(binding, error)
                                    )

                            default:
                                break
                        }
                    },
                    receiveCancel: { [weak dispatcher] in

                        dispatcher?
                            ._bindingsViewModelStatusLog
                            .send(
                                .cancelled(binding)
                            )
                    }
                )
                .eraseToAnyPublisher()
        }
    }
}
