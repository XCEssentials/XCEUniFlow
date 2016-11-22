//
//  Main.swift
//  MKHUniFlow
//
//  Created by Maxim Khatskevich on 10/20/16.
//  Copyright © 2016 Maxim Khatskevich. All rights reserved.
//

import Foundation

//===

public
protocol UFLModel { }

//===

public
typealias UFLStateMutation<Model: UFLModel> = (_ state: inout Model) -> Void

public
func UFLNoStateMutation<Model: UFLModel>() -> UFLStateMutation<Model>
{
    return { _ in /* do nothing*/ }
}

//===

public
struct UFLNoInput { }

//===

public
typealias UFLAction<Model: UFLModel, Input> =
    (
    _ input: Input,
    _ currentState: Model,
    _ dispatcher: UFLDispatcher<Model>
    )
    throws -> UFLStateMutation<Model>

//===

public
typealias UFLActionShort<Model: UFLModel> =
    (
    _ currentState: Model,
    _ dispatcher: UFLDispatcher<Model>
    )
    throws -> UFLStateMutation<Model>

//===

public
typealias UFLTrigger<Model: UFLModel, Input> =
    (
    _ input: Input,
    _ currentState: Model,
    _ dispatcher: UFLDispatcher<Model>
    )
    throws -> Void

//===

public
typealias UFLTriggerShort<Model: UFLModel> =
    (
    _ currentState: Model,
    _ dispatcher: UFLDispatcher<Model>
    )
    throws -> Void

//===

public
typealias UFLModelConverter<Model: UFLModel> = (_ globalModel: Model) -> Any?

//===

public
typealias UFLUpdateHandler = (_ state: Any) -> Void

//===

public
struct UFLPendingSubscription<Model: UFLModel>
{
    fileprivate
    let observer: AnyObject
    
    fileprivate
    let dispatcher: UFLDispatcher<Model>
    
    fileprivate
    let modelConverter: UFLModelConverter<Model>
    
    fileprivate
    let updateHandler: UFLUpdateHandler
    
    public
    func onConvertModel<SubModel>(
        _ converter: @escaping (_ globalModel: Model) -> SubModel?
        ) -> UFLPendingSubscription
    {
        return
            UFLPendingSubscription(
                observer: observer,
                dispatcher: dispatcher,
                modelConverter: converter,
                updateHandler: updateHandler)
    }
    
    public
    func onUpdate<SubModel>(
        _ handler: @escaping (_ state: SubModel) -> Void
        ) -> UFLPendingSubscription
    {
        return
            UFLPendingSubscription(
                observer: observer,
                dispatcher: dispatcher,
                modelConverter: modelConverter,
                updateHandler: { handler($0 as! SubModel) })
    }
    
    public
    func activate(initialUpdate: Bool = true)
    {
        dispatcher
            .subscribe(
                observer,
                subscription: UFLSubscription(modelConverter, updateHandler),
                initialUpdate: initialUpdate)
    }
}

//===

private
final
class UFLSubscription<Model: UFLModel> // must be an object (class) to work with NSMapTable
{
    let modelConverter: UFLModelConverter<Model>
    let updateHandler: UFLUpdateHandler
    
    init(_ modelConverter: @escaping UFLModelConverter<Model>, _ updateHandler: @escaping UFLUpdateHandler)
    {
        self.modelConverter = modelConverter
        self.updateHandler = updateHandler
    }
}

//===

public
final
class UFLDispatcher<Model: UFLModel>
{
    //=== MARK: Private members
    
    private
    var state: Model
    
    //=== MARK: Public types
    
    public
    typealias UFLOnActionRejected = (_ error: Error) -> Void
    
    //=== MARK: Public members
    
    public
    var onActionRejected: UFLOnActionRejected?
    
    //=== Initializer
    
    public
    required
    init(_ initialState: Model)
    {
        state = initialState
    }
    
    //=== MARK: Public functions
    
    public
    func prepareSubscription(_ observer: AnyObject) -> UFLPendingSubscription<Model>
    {
        return
            UFLPendingSubscription(
                observer: observer,
                dispatcher: self,
                modelConverter: { $0 /*just return what we got as input*/ },
                updateHandler: { (_) in /*do nothing*/ })
    }
    
    public
    func unsubscribe(_ observer: AnyObject)
    {
        subscriptions
            .removeObject(forKey: observer)
    }
    
    public
    func submit<Input>(_ action: @escaping UFLAction<Model, Input>, with input: Input)
    {
        OperationQueue
            .main
            .addOperation {
                
                // we add this action to queue async-ly,
                // to make sure it will be processed AFTER
                // current execution is completes,
                // that even allows from an Action handler
                // to submit another Action
                
                self.process(action, input: input)
        }
    }
    
    public
    func submit(_ actionShort: @escaping UFLActionShort<Model>)
    {
        let action: UFLAction<Model, UFLNoInput> = {
            
            return try actionShort($1, $2)
        }
        
        //===
        
        submit(action, with: UFLNoInput())
    }
    
    public
    func submit<Input>(_ trigger: @escaping UFLTrigger<Model, Input>, with input: Input)
    {
        let action: UFLAction<Model, Input> = {
            
            try trigger($0, $1, $2)
            
            //===
            
            return UFLNoStateMutation()
        }
        
        //===
        
        submit(action, with: input)
    }
    
    public
    func submit(_ triggerShort: @escaping UFLTriggerShort<Model>)
    {
        let action: UFLAction<Model, UFLNoInput> = {
            
            try triggerShort($1, $2)
            
            //===
            
            return UFLNoStateMutation()
        }
        
        //===
        
        submit(action, with: UFLNoInput())
    }
    
    public
    func submit(directly mutation: @escaping UFLStateMutation<Model>)
    {
        let action: UFLAction<Model, UFLNoInput> = { _, _, _ in
            
            return mutation
        }
        
        //===
        
        submit(action, with: UFLNoInput())
    }
    
    //=== MARK: Private members
    
    private
    var subscriptions =
        NSMapTable<AnyObject, UFLSubscription<Model>>(keyOptions: .weakMemory,
                                                      valueOptions: .strongMemory)
    
    //=== MARK: Private functions
    
    private
    func process<Input>(_ action: @escaping UFLAction<Model, Input>, input: Input)
    {
        do
        {
            let mutation = try action(input, state, self)
            
            mutation(&state)
            
            //===
            
            notifySubscriptions()
        }
        catch
        {
            // action has thrown,
            // will NOT notify subscribers
            // about attempt to process this action
            
            onActionRejected.map { $0(error) }
        }
    }
    
    fileprivate
    func subscribe(_ observer: AnyObject,
                   subscription: UFLSubscription<Model>,
                   initialUpdate: Bool = true)
    {
        subscriptions
            .setObject(subscription, forKey: observer)
        
        //===
        
        if initialUpdate
        {
            notifySubscription(subscription)
        }
    }
    
    private
    func notifySubscriptions()
    {
        _ = subscriptions
            .objectEnumerator()?
            .allObjects
            .flatMap({ $0 as? UFLSubscription })
            .map(notifySubscription)
    }
    
    private
    func notifySubscription(_ subscription: UFLSubscription<Model>)
    {
        subscription
            .modelConverter(state)
            .map(subscription.updateHandler)
    }
}

//=== MARK: - UFLFeature

public
protocol UFLFeature { }

//=== MARK: - UFLContext

public
protocol UFLContext { }

//=== MARK: - UFLDelegate

public
protocol UFLDelegate
{
    associatedtype Model: UFLModel
    associatedtype SubModel
    associatedtype Context: UFLContext
    
    init(dispatcher: UFLDispatcher<Model>, context: Context?)
    
    func subscribe(
        _ observer: AnyObject,
        onUpdate handler: @escaping (_ state: SubModel) -> Void)
    
    func unsubscribe(_ observer: AnyObject)
}

//=== MARK: - UFLConfigurable

public
protocol UFLConfigurable // potential subscriber/observer
{
    associatedtype Delegate: UFLDelegate
    
    typealias SubModel = Delegate.SubModel
    
    init(delegate: Delegate)
    func configure(with model: SubModel)
}

//=== MARK: - UFLDispatcherBindable

public
protocol UFLDispatcherBindable: class
{
    associatedtype Model: UFLModel
    
    func bind(with dispatcher: UFLDispatcher<Model>) -> Self
}

//=== MARK: - UFLDispatcherInitializable

public
protocol UFLDispatcherInitializable: class
{
    associatedtype Model: UFLModel
    
    init(with dispatcher: UFLDispatcher<Model>)
}

//===

public
struct UFLActionRejected: Error
{
    public
    let action: String
    
    public
    let reason: String
    
    //===
    
    public
    init(action: String, because reason: String? = nil)
    {
        self.action = action
        self.reason = (reason ?? "State did not satisfy pre-conditions.")
    }
}

//===

public
func UFLReject(because reason: String? = nil,
               actionNameFull: String = #function) -> UFLActionRejected
{
    return UFLActionRejected(action: Helpers.actionName(from: actionNameFull),
                             because: reason)
}

//===

enum Helpers
{
    static
        func actionName(from fullName: String) -> String
    {
        return fullName.components(separatedBy: "(").first ?? ""
    }
}

//===

public
extension UFLDispatcher
{
    public
    func enableDefaultReporting()
    {
        onActionRejected = { (err: Error) in
            
            if
                let err = err as? UFLActionRejected
            {
                print("MKHUniFlow: [-] Action '\(err.action)'  REJECTED, reason: \(err.reason)")
            }
            else
            {
                print("MKHUniFlow: [-] Action REJECTED, error: \(err)")
            }
        }
    }
}
