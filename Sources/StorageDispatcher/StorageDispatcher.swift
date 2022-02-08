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
    enum AccessError: Error
    {
        case notOnMainThread
        case noActiveTransaction
        case anotherTransactionIsInProgress
        case concurrentChangesDetected
        
        case errorDuringExecution(
            scope: String,
            context: String,
            location: Int,
            Error
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
        var bindingsStatusLog: AnyPublisher<BindingStatus, Never>
        {
            dispatcher
                ._bindingsStatusLog
                .eraseToAnyPublisher()
        }
    }
    
    fileprivate
    typealias Transaction = (
        scope: String,
        context: String,
        location: Int,
        tmpStorageCopy: ByTypeStorage,
        lastHistoryResetId: String
    )
    
    fileprivate
    typealias AccessLog = PassthroughSubject<AccessReport, Never>
 
    fileprivate
    typealias Status = CurrentValueSubject<[FeatureStatus], Never>
    
    fileprivate
    typealias BindingsStatusLog = PassthroughSubject<BindingStatus, Never>
    
    //---
    
    private
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
    let _bindingsStatusLog = BindingsStatusLog()
    
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
    
    func removeAll(
        scope: String = #file,
        context: String = #function,
        location: Int = #line
    ) throws {
        
        try access(scope: scope, context: context, location: location) {
           
            try $0.removeAll()
        }
    }
}

//internal
extension StorageDispatcher
{
    func startTransaction(
        scope: String = #file,
        context: String = #function,
        location: Int = #line
    ) throws {
        
        try Thread.isMainThread ?! AccessError.notOnMainThread
        try (activeTransaction == nil) ?! AccessError.anotherTransactionIsInProgress
        
        //---
        
        activeTransaction = (
            scope,
            context,
            location,
            storage,
            storage.lastHistoryResetId
        )
    }
    
    @discardableResult
    func commitTransaction() throws -> ByTypeStorage.History
    {
        try Thread.isMainThread ?! AccessError.notOnMainThread
        
        guard
            var transaction = self.activeTransaction
        else
        {
            throw AccessError.noActiveTransaction
        }
        
        try (transaction.lastHistoryResetId == storage.lastHistoryResetId) ?! AccessError.concurrentChangesDetected
        
        //---
        
        let mutationsToReport = transaction.tmpStorageCopy.resetHistory()
        
        // apply changes to permanent storage
        storage = transaction.tmpStorageCopy // NOTE: the history has already been cleared

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
                    scope: transaction.scope,
                    context: transaction.context,
                    location: transaction.location
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
        reason: Error
    ) throws {
        
        try Thread.isMainThread ?! AccessError.notOnMainThread
        
        guard
            let transaction = self.activeTransaction
        else
        {
            throw AccessError.noActiveTransaction
        }
        
        //---
        
        _accessLog.send(
            .init(
                outcome: .rejected(
                    reason: reason
                    ),
                storage: storage,
                env: .init(
                    scope: transaction.scope,
                    context: transaction.context,
                    location: transaction.location
                )
            )
        )
        
        //---
        
        self.activeTransaction = nil
    }
    
    func access(
        scope: String = #file,
        context: String = #function,
        location: Int = #line,
        _ handler: AccessHandler
    ) throws {
        
        try Thread.isMainThread ?! AccessError.notOnMainThread
        
        guard
            var tmpStorageCopy = activeTransaction?.tmpStorageCopy
        else
        {
            throw AccessError.noActiveTransaction
        }
        
        //---

        do
        {
            try handler(&tmpStorageCopy)
        }
        catch
        {
            throw AccessError.errorDuringExecution(
                scope: scope,
                context: context,
                location: location,
                error
            )
        }
        
        activeTransaction?.tmpStorageCopy = tmpStorageCopy
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
struct MutationBinding
{
    public
    enum Source
    {
        case inStoreBinding(SomeStateful.Type)
        case externalBinding(SomeViewModel.Type)
    }

    public
    let source: Source
    
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
        
        self.source = .inStoreBinding(S.self)
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
                            ._bindingsStatusLog
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
                            ._bindingsStatusLog
                            .send(
                                .activated(binding)
                            )
                    },
                    receiveOutput: { [weak dispatcher] _ in

                        dispatcher?
                            ._bindingsStatusLog
                            .send(
                                .executed(binding)
                            )
                    },
                    receiveCompletion: { [weak dispatcher] in

                        switch $0
                        {
                            case .failure(let error):

                                dispatcher?
                                    ._bindingsStatusLog
                                    .send(
                                        .failed(binding, error)
                                    )

                            default:
                                break
                        }
                    },
                    receiveCancel: { [weak dispatcher] in

                        dispatcher?
                            ._bindingsStatusLog
                            .send(
                                .cancelled(binding)
                            )
                    }
                )
                .eraseToAnyPublisher()
        }
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
        
        self.source = .externalBinding(S.self)
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
                            ._bindingsStatusLog
                            .send(
                                .triggered(binding)
                            )
                    }
                )
                .compactMap { [weak dispatcher, weak source] (givenOutput: G) -> Void? in

                    guard let dispatcher = dispatcher else { return nil }
                    guard let source = source else { return nil }

                    //---

                    return then(source, givenOutput, dispatcher.proxy) // map into `Void` to erase type info
                }
                .handleEvents(
                    receiveSubscription: { [weak dispatcher] _ in

                        dispatcher?
                            ._bindingsStatusLog
                            .send(
                                .activated(binding)
                            )
                    },
                    receiveOutput: { [weak dispatcher] _ in

                        dispatcher?
                            ._bindingsStatusLog
                            .send(
                                .executed(binding)
                            )
                    },
                    receiveCompletion: { [weak dispatcher] in

                        switch $0
                        {
                            case .failure(let error):

                                dispatcher?
                                    ._bindingsStatusLog
                                    .send(
                                        .failed(binding, error)
                                    )

                            default:
                                break
                        }
                    },
                    receiveCancel: { [weak dispatcher] in

                        dispatcher?
                            ._bindingsStatusLog
                            .send(
                                .cancelled(binding)
                            )
                    }
                )
                .eraseToAnyPublisher()
        }
    }
}
