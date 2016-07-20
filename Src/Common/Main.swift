//
//  UniFlow.swift
//  Vango
//
//  Created by Maxim Khatskevich on 2/10/16.
//  Copyright © 2016 Maxim Khatskevich. All rights reserved.
//

import Foundation

//=== MARK: GlobalModel

public
protocol UFLModel { }

//=== MARK: - Update State

public
typealias UFLUpdateState = (inout state: UFLModel) -> Void

//=== MARK: - Action

public
protocol UFLAction
{
    func main(dispatcher: UFLDispatcher, state: UFLModel) throws -> UFLUpdateState
    func onSuccess(dispatcher: UFLDispatcher, state: UFLModel) -> Void
}

public
extension UFLAction
{
    func rejected(reason: String? = nil) -> UFLActionRejected
    {
        // 'throw' result of this function
        // when current state does not satisfy pre-conditions
        
        return UFLActionRejected(action: self, reason: reason)
    }
    
    func onSuccess(dispatcher: UFLDispatcher, state: UFLModel) -> Void
    {
        // this is called after 'perform...'
        // ONLY if 'perform' has NOT been rejected,
        // when all changes from this Action
        // are already applied to (global) 'state'
        
        //===
        
        // this function doesn't do anything by default
        
        // override this function in a custom Action
        // to implement any kind of explicit side effect
        // logically related to this specific Action,
        // instead of observing for this Action
        // in a global observer
        
        //===
        
        // REMEMBER: Action is implicitly defined by context,
        // all Action input params (internal members) are availalbe.
    }
}

//===

public
struct UFLActionRejected: ErrorType
{
    let action: UFLAction
    let reason: String
    
    //===
    
    init(action: UFLAction, reason: String? = nil)
    {
        self.action = action
        self.reason = (reason ?? "State did not satisfy pre-conditions.")
    }
}

//===

public
protocol UFLTrigger: UFLAction
{
    // This kind of actions supposed to just trigger other actions
    // using dispatcher, without any changes to current state.
    
    func main(dispatcher: UFLDispatcher, state: UFLModel) throws
}

public
extension UFLTrigger
{
    func main(dispatcher: UFLDispatcher, state: UFLModel) throws -> UFLUpdateState
    {
        try main(dispatcher, state: state)
        
        //===
        
        return { $0 /* do nothing */ }
    }
}

//===

public
protocol UFLNotification: UFLAction
{
    // This kind of actions supposed to just notify observers about somthing,
    // without any changes to current state.
}

public
extension UFLNotification
{
    func main(dispatcher: UFLDispatcher, state: UFLModel) throws -> UFLUpdateState
    {
        /* do nothing */
        
        //===
        
        return { $0 /* do nothing */ }
    }
}

//=== MARK: - UFLDispatcherAware

public
protocol UFLDispatcherBindable: class
{
    func bind(dispatcher: UFLDispatcher) -> Self
}

//=== MARK: - UFLDispatcherInitializable

public
protocol UFLDispatcherInitializable: class
{
    init(dispatcher: UFLDispatcher)
}

//=== MARK: - Dispatcher

public
final
class UFLDispatcher: NSObject
{
    //=== MARK: Private members
    
    private
    var state: UFLModel
    
    private
    var globalObservers: [AnyObject] = []
    
    private
    var subscriptions = NSMapTable(keyOptions: .WeakMemory, valueOptions: .StrongMemory)
    
    //=== MARK: Private types
    
    private
    final
    class UFLSubscription
    {
        let modelConverter: UFLModelConverter
        let updateHandler: UFLUpdateHandler
        
        init(_ modelConverter: UFLModelConverter, _ updateHandler: UFLUpdateHandler)
        {
            self.modelConverter = modelConverter
            self.updateHandler = updateHandler
        }
    }
    
    //=== Initializer
    
    public
    init(initialState: UFLModel)
    {
        state = initialState
    }
    
    //=== MARK: Public types
    
    public
    struct InitialUpdate: UFLNotification { }
    
    public
    typealias UFLActionBlock = (dispatcher: UFLDispatcher, state: UFLModel) throws -> UFLUpdateState
    
    public
    typealias UFLModelConverter = (globalModel: UFLModel) -> Any? // return SubModel
    
    public
    typealias UFLUpdateHandler = (state: Any, action: UFLAction) -> Void
    
    public
    struct UFLPendingSubscription
    {
        private
        let key: AnyObject
        
        private
        let dispatcher: UFLDispatcher
        
        private
        let modelConverter: UFLModelConverter
        
        private
        let updateHandler: UFLUpdateHandler
        
        public
        func onConvertModel<GlobalModelType, SubModelType>(
            customModelConverter: (globalModel: GlobalModelType) -> SubModelType?
            ) -> UFLPendingSubscription
        {
            let converter: UFLModelConverter = { model in
                
                return customModelConverter(globalModel: model as! GlobalModelType)
            }
            
            //===
            
            return
                UFLPendingSubscription(
                    key: key,
                    dispatcher: dispatcher,
                    modelConverter: converter,
                    updateHandler: updateHandler)
        }
        
        public
        func onUpdate<SubModelType: Any>(
            customUpdateHandler: (state: SubModelType, action: UFLAction) -> Void
            ) -> UFLPendingSubscription
        {
            let handler: UFLUpdateHandler = { state, action in
                
                return customUpdateHandler(state: state as! SubModelType, action: action)
            }
            
            //===
            
            return
                UFLPendingSubscription(
                    key: key,
                    dispatcher: dispatcher,
                    modelConverter: modelConverter,
                    updateHandler: handler)
        }
        
        public
        func activate(initialUpdate: Bool = true)
        {
            dispatcher
                .subscribe(
                    key,
                    subscription: UFLSubscription(modelConverter, updateHandler),
                    initialUpdate: initialUpdate)
        }
    }
    
    public
    typealias OnActionProcessed = (action: UFLAction) -> Void
    
    public
    typealias OnActionRejected = (action: UFLAction, error: ErrorType) -> Void
    
    //=== MARK: Public members
    
    public
    var onActionProcessed: OnActionProcessed?
    
    public
    var onActionRejected: OnActionRejected?
    
    //=== MARK: Public functions
    
    public
    func prepareSubscription(observer: AnyObject) -> UFLPendingSubscription
    {
        return
            UFLPendingSubscription(
                key: observer,
                dispatcher: self,
                modelConverter: { $0 },
                updateHandler: { $0 })
    }
    
    public
    func unsubscribe(observer: AnyObject)
    {
        subscriptions.removeObjectForKey(observer)
    }
    
    public
    func submit(action: UFLAction)
    {
        self.submit(action, actionBlock: action.main)
    }
    
    //=== MARK: Private functions
    
    private
    func submit(action: UFLAction, actionBlock: UFLActionBlock)
    {
        NSOperationQueue
            .mainQueue()
            .addOperationWithBlock {
                
                // we add this action to queue async-ly,
                // to make sure it will be processed AFTER
                // current execution is completes,
                // that even allows from an Action handler
                // to submit another Action
                
                self.process(action, actionBlock: actionBlock)
        }
    }
    
    private
    func process(action: UFLAction, actionBlock: UFLActionBlock)
    {
        do
        {
            try actionBlock(dispatcher: self, state: state)(state: &state)
            
            //===
            
            action.onSuccess(self, state: state)
            
            //===
            
            notifySubscriptions(action)
            
            //===
            
            if
                let handler = onActionProcessed
            {
                handler(action: action)
            }
        }
        catch
        {
            // action has thrown,
            // will NOT notify subscribers
            // about attempt to process this action
            
            if
                let handler = onActionRejected
            {
                handler(action: action, error: error)
            }
        }
    }
    
    private
    func subscribe(observer: AnyObject, subscription: UFLSubscription, initialUpdate: Bool = true)
    {
        subscriptions.setObject(subscription, forKey: observer)
        
        //===
        
        if initialUpdate
        {
            notifySubscription(subscription, action: InitialUpdate())
        }
    }
    
    private
    func notifySubscriptions(action: UFLAction)
    {
        for key in subscriptions.keyEnumerator().allObjects
        {
            notifySubscription(
                subscriptions.objectForKey(key) as! UFLSubscription,
                action: action)
        }
    }
    
    private
    func notifySubscription(subscription: UFLSubscription, action: UFLAction)
    {
        if
            let subModel = subscription.modelConverter(globalModel: state)
        {
            subscription
                .updateHandler(state: subModel, action: action)
        }
    }
}

//=== MARK: - ObjC compatibility

public
extension UFLDispatcher
{
    @objc
    public
    func subscribeWithObserver(
        observer: AnyObject,
        onPrepare: (globalModel: AnyObject) -> AnyObject?,
        onUpdate: (state: AnyObject, actionName: String) -> Void)
    {
        prepareSubscription(observer)
            .onConvertModel(onPrepare)
            .onUpdate({ (state, action) in
                
                onUpdate(state: state, actionName: String(reflecting: action.dynamicType.self))
            })
            .activate()
    }

    @objc
    public
    func subscribeWithObserver(
        observer: AnyObject,
        onUpdate: (state: AnyObject, actionName: String) -> Void)
    {
        prepareSubscription(observer)
            .onConvertModel({ $0 as AnyObject })
            .onUpdate({ (state, action) in

                onUpdate(state: state, actionName: String(reflecting: action.dynamicType.self))
            })
            .activate()
    }
}
