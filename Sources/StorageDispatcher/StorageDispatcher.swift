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

//---

public
final
class StorageDispatcher
{
    fileprivate
    typealias AccessLog = PassthroughSubject<AccessReport, Never>
 
    fileprivate
    typealias Status = CurrentValueSubject<[FeatureStatus], Never>
    
    fileprivate
    typealias BindingsStatusLog = PassthroughSubject<AccessReportBindingStatus, Never>
    
    //---
    
    private
    var storage: ByTypeStorage
    
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
    
    //---
    
    public
    var accessLog: AnyPublisher<AccessReport, Never>
    {
        _accessLog
            .eraseToAnyPublisher()
    }
    
    public
    var status: AnyPublisher<[FeatureStatus], Never>
    {
        _status
            .eraseToAnyPublisher()
    }
    
    public
    var bindingsStatusLog: AnyPublisher<AccessReportBindingStatus, Never>
    {
        _bindingsStatusLog
            .eraseToAnyPublisher()
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
        
        self.statusSubscription = accessLog
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
    var allValues: [SomeStorableBase]
    {
        storage.allValues
    }
    
    var allKeys: [SomeKey.Type]
    {
        storage.allKeys
    }
    
    typealias AccessHandler = (inout ByTypeStorage) throws -> Void
    
    enum AccessError: Error
    {
        case concurrentMutatingAccessDetected
    }

    /// Transaction-like isolation for mutations on the storage.
    @discardableResult
    func access(
        scope: String = #file,
        context: String = #function,
        location: Int = #line,
        _ handler: AccessHandler
    ) throws -> ByTypeStorage.History {
        
        assert(Thread.isMainThread, "Must be on main thread!")
        
        //---
        
        // we want to avoid partial changes to be applied in case the handler throws
        var tmpCopyStorage = storage
        let lastHistoryResetId = tmpCopyStorage.lastHistoryResetId
        
        //---
        
        let mutationsToReport: ByTypeStorage.History
        
        do
        {
            try handler(&tmpCopyStorage) // NOTE: another call to `access` can be made inside
            
            //---
            
            mutationsToReport = tmpCopyStorage.resetHistory()
            
            //---
            
            switch lastHistoryResetId == storage.lastHistoryResetId // still the same snapshot?
            {
                // no concurrent mutations have been done:
                case true where !mutationsToReport.isEmpty: // and we have mutations to save
                    
                    // apply changes to permanent storage
                    storage = tmpCopyStorage // NOTE: the history has already been cleared
                    
                // seems like another concurrent mutating access has been done:
                case false where !mutationsToReport.isEmpty: // and we have mutations here
                    
                    // the API has been misused - mutations here and in a nested transaction?
                    throw AccessError.concurrentMutatingAccessDetected
                    
                default:
                    // if concurrent mutations have been applied, but we don't have mutations
                    // here - it's totally fine to ignore, we jsut do nothing - no error, but also
                    // IMPORTANT to NOTE: we do NOT apply the temporary copy back to the storage!
                    break
            }
        }
        catch
        {
            _accessLog.send(
                .init(
                    outcome: .rejected(
                        reason: error /// NOTE: error from `handler` or `AccessError`
                        ),
                    storage: storage,
                    env: .init(
                        scope: scope,
                        context: context,
                        location: location
                    )
                )
            )
            
            //---
            
            throw error
        }
        
        //---
        
        installBindings(
            basedOn: mutationsToReport
        )
        
        //---
        
        _accessLog.send(
            .init(
                outcome: .processed(
                    mutations: mutationsToReport
                ),
                storage: storage,
                env: .init(
                    scope: scope,
                    context: context,
                    location: location
                )
            )
        )
        
        //---
        
        uninstallBindings(
            basedOn: mutationsToReport
        )
        
        //---
        
        return mutationsToReport
    }
    
    @discardableResult
    func removeAll(
        scope: String = #file,
        context: String = #function,
        location: Int = #line
    ) throws -> ByTypeStorage.History {
        
        try access(scope: scope, context: context, location: location) {
           
            try $0.removeAll()
        }
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
            .compactMap { report -> SomeKey.Type? in
                
                switch report.outcome
                {
                    case .initialization(let key, _):
                        return key
                        
                    default:
                        return nil
                }
            }
            .map {(
                key: $0,
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
                
                self.bindings[$0.key.name] = $0.bindings
            }
    }
    
    /// This will uninstall bindings for recently deinitialized keys.
    func uninstallBindings(
        basedOn reports: ByTypeStorage.History
    ) {
        assert(Thread.isMainThread, "Must be on main thread!")
        
        //---
        
        reports
            .compactMap { report -> SomeKey.Type? in
                
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

// MARK: - Binding - Internal

public
struct AccessReportBinding: SomeAccessReportBinding
{
    public
    let source: AccessReportBindingSource
    
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
    
    public
    func construct(with dispatcher: StorageDispatcher) -> AnyCancellable
    {
        body(dispatcher, self).sink(receiveCompletion: { _ in }, receiveValue: { })
    }
    
    public
    init<S: SomeKey, W: Publisher, G>(
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
        
        self.source = .keyType(S.self)
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
}

// MARK: - Binding - External

public
struct AccessReportBindingExt: SomeAccessReportBinding
{
    public
    let source: AccessReportBindingSource
    
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
    
    public
    func construct(with dispatcher: StorageDispatcher) -> AnyCancellable
    {
        body(dispatcher, self).sink(receiveCompletion: { _ in }, receiveValue: { })
    }
    
    public
    init<S: SomeStorageObserver, W: Publisher, G>(
        source: S,
        description: String,
        scope: String,
        location: Int,
        when: @escaping (AnyPublisher<StorageDispatcher.AccessReport, Never>) -> W,
        given: @escaping (StorageDispatcher, W.Output) throws -> G?,
        then: @escaping (S, G) -> Void
    ) {
        assert(Thread.isMainThread, "Must be on main thread!")
        
        //---
        
        self.source = .observerType(S.self)
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
                            ._bindingsStatusLog
                            .send(
                                .triggered(binding)
                            )
                    }
                )
                .compactMap { [weak source] (givenOutput: G) -> Void? in

                    guard let source = source else { return nil }

                    //---

                    return then(source, givenOutput) // map into `Void` to erase type info
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
