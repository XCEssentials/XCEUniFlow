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

import Combine

//---

@MainActor
public
final
class Dispatcher
{
    public internal(set)
    var storage: StateStorage
    
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
    
    public
    init(
        with storage: StateStorage? = nil
    ) {
        self.storage = storage ?? .init()
        
        //---
        
        self.statusSubscription = accessLog
            .onProcessed
            .statusReport
            .sink { [weak self] in
                self?._status.send($0)
            }
    }
}

// MARK: - Transactions support

//internal
extension Dispatcher
{
    @discardableResult
    func transact<F: Feature, T>(
        scope s: String,
        context c: String,
        location l: Int,
        _ handler: (inout TransactionContext<F>) throws -> T
    ) rethrows -> T {

        let storageBefore = storage
        
        //---
        
        do
        {
            var txContext = TransactionContext<F>(dispatcher: self)
            let output = try handler(&txContext)
            let mutationsToReport = storage.resetHistory()
            
            let report = AccessReport(
                outcome: .success(mutationsToReport),
                storage: storage,
                origin: .init(
                    file: s,
                    function: c,
                    line: l
                )
            )
            
            installInternalBindings(basedOn: mutationsToReport)
            _accessLog.send(report)
            uninstallInternalBindings(basedOn: mutationsToReport)
            
            //---

            return output
        }
        catch
        {
            storage = storageBefore //rollback global state
            
            let report = AccessReport(
                outcome: .failure(
                    error
                ),
                storage: storage,
                origin: .init(
                    file: s,
                    function: c,
                    line: l
                )
            )
            
            _accessLog.send(report)
            
            //---

            throw error
        }
    }
}

// MARK: - External mutations observation

public
extension Dispatcher
{
    /// Designeted convenience shortcut for observing all mutations
    /// within scope of this dispatcher.
    func on<T: MutationDecriptor>( _: T.Type) -> AnyPublisher<T, Never>
    {
        accessLog.onProcessed.perEachMutation.as(T.self)
    }
}

// MARK: - Internal bindings management

private
extension Dispatcher
{
    /// Install bindings for newly initialized keys.
    func installInternalBindings(
        basedOn reports: StateStorage.History
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
    
    /// Uninstall bindings for recently deinitialized keys.
    func uninstallInternalBindings(
        basedOn reports: StateStorage.History
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
@MainActor
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
        when: @escaping (AnyPublisher<AccessReport, Never>) -> W,
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
