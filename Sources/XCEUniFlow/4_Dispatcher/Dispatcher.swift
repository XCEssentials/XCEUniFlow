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
    var currentTransaction: AccessOrigin?
    
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

// MARK: - Nested errors

public
extension Dispatcher
{
    struct NestedTransactonError: Error
    {
        public
        let anotherTransactionOrigin: AccessOrigin
    }
}

// MARK: - Transactions support

//internal
extension Dispatcher
{
    /// Execute transaction represented by `handler`.
    ///
    /// - Returns: outcome of the transaction `handler`.
    ///
    /// - Throws: `NestedTransactonError` if another active
    ///     transaction has been already started.
    @discardableResult
    func transact<T>(
        file: StaticString,
        function: StaticString,
        line: UInt,
        _ handler: (inout TransactionContext) throws -> T
    ) throws -> Result<T, Error> {
        
        if
            let tx = currentTransaction
        {
            throw NestedTransactonError(anotherTransactionOrigin: tx)
        }
        
        //---
        
        let storageBefore = storage
        
        //---
        
        do
        {
            currentTransaction = .init(
                file: file,
                function: function,
                line: line
            )
            
            var txContext = TransactionContext(dispatcher: self)
            let output = try handler(&txContext)
            let mutationsToReport = storage.resetHistory()
            
            let report = AccessReport(
                outcome: .success(mutationsToReport),
                storage: storage,
                origin: .init(
                    file: file,
                    function: function,
                    line: line
                )
            )
            
            currentTransaction = nil
            
            installInternalBindings(basedOn: mutationsToReport)
            _accessLog.send(report)
            uninstallInternalBindings(basedOn: mutationsToReport)
            
            //---

            return .success(output)
        }
        catch
        {
            currentTransaction = nil
            
            storage = storageBefore //rollback global state
            
            let report = AccessReport(
                outcome: .failure(
                    error
                ),
                storage: storage,
                origin: .init(
                    file: file,
                    function: function,
                    line: line
                )
            )
            
            _accessLog.send(report)
            
            //---

            return .failure(error)
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
        accessLog
            .onProcessed
            .perEachMutation
            .compactMap(T.init(from:))
            .eraseToAnyPublisher()
    }
    
    enum MutationObservingError: Error
    {
        /// It is expected that observation awaiting will last indefinitely,
        /// until expected mutation happens, so if it returns `nil` then
        /// something unexpected happened with corresponding underlaying
        /// notification stream - then we throw this error.
        case asyncObservationEndedUnexpectedly
    }
    
    /// Designeted convenience shortcut for observing all mutations
    /// within scope of this dispatcher.
    @available(macOS 12.0, *)
    func when<M: MutationDecriptor>(
        _: M.Type
    ) async throws -> M {
        
        guard
            let mutation = await on(M.self) // filter for certain mutation type
                .values
                .first(where: { _ in true }) // no further filtering is necessary
        else
        {
            throw MutationObservingError
                .asyncObservationEndedUnexpectedly
        }
        
        return mutation
    }
    
    /// Designeted convenience shortcut for observing all mutations
    /// within scope of this dispatcher, with additional custom
    /// `given` clause for precise filtering and simultanious value
    /// extraction.
    @available(macOS 12.0, *)
    func when<M: MutationDecriptor, R>(
        _: M.Type,
        given: (M) throws -> R?
    ) async throws -> R {
        
        var resultMaybe: Result<R, Error>? = nil
        
        //---
        
        guard
            let _ = await on(M.self) // filter for certain mutation type
                .values
                .first(where: {
                    
                    mutation in
                    
                    //---
                    
                    do
                    {
                        if
                            let output = try given(mutation)
                        {
                            resultMaybe = .success(output)
                        }
                    }
                    catch
                    {
                        resultMaybe = .failure(error)
                    }
                    
                    //---
                    
                    /// Return `true` if we received a result,
                    /// which means we are done waiting and can
                    /// end this awaiting.
                    
                    return resultMaybe != nil
                }),
            let result = resultMaybe
        else
        {
            throw MutationObservingError
                .asyncObservationEndedUnexpectedly
        }
        
        //---
        
        return try result.get()
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
    let file: StaticString
    
    public
    let source: Feature.Type
    
    public
    let line: UInt
    
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
        file: StaticString,
        line: UInt,
        when: @escaping (AnyPublisher<AccessReport, Never>) -> W,
        given: @escaping (Dispatcher, W.Output) throws -> G?,
        then: @escaping (Dispatcher, G) -> Void
    ) where W.Failure == Never {
        
        self.source = S.self
        self.description = description
        self.file = file
        self.line = line
        
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
