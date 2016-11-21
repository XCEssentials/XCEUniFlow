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
typealias UFLUpdateState = (_ /*state*/: inout UFLModel) -> Void

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
struct UFLActionRejected: Error
{
    public
    let action: UFLAction
    
    public
    let reason: String
    
    //===
    
    public
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
        try main(dispatcher: dispatcher, state: state)
        
        //===
        
        return { (_) in /* do nothing */ }
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
        
        return { (_) in /* do nothing */ }
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
    var subscriptions = NSMapTable<AnyObject, UFLSubscription>(keyOptions: .weakMemory, valueOptions: .strongMemory)
    
    //=== MARK: Private types
    
    private
    final
    class UFLSubscription
    {
        let modelConverter: UFLModelConverter
        let updateHandler: UFLUpdateHandler
        
        init(_ modelConverter: @escaping UFLModelConverter, _ updateHandler: @escaping UFLUpdateHandler)
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
    typealias UFLActionBlock = (_ /*dispatcher*/: UFLDispatcher, _ /*state*/: UFLModel) throws -> UFLUpdateState
    
    public
    typealias UFLModelConverter = (_ /*globalModel*/: UFLModel) -> Any? // return SubModel
    
    public
    typealias UFLUpdateHandler = (_ /*state*/: Any, _ /*action*/: UFLAction) -> Void
    
    public
    struct UFLPendingSubscription
    {
        fileprivate
        let key: AnyObject
        
        fileprivate
        let dispatcher: UFLDispatcher
        
        fileprivate
        let modelConverter: UFLModelConverter
        
        fileprivate
        let updateHandler: UFLUpdateHandler
        
        public
        func onConvertModel<GlobalModelType, SubModelType>(
            _ customModelConverter: @escaping (_ /*globalModel*/: GlobalModelType) -> SubModelType?
            ) -> UFLPendingSubscription
        {
            let converter: UFLModelConverter = { model in
                
                return customModelConverter(model as! GlobalModelType)
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
            _ customUpdateHandler: @escaping (_ /*state*/: SubModelType, _ /*action*/: UFLAction) -> Void
            ) -> UFLPendingSubscription
        {
            let handler: UFLUpdateHandler = { state, action in
                
                return customUpdateHandler(state as! SubModelType, action)
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
                    observer: key,
                    subscription: UFLSubscription(modelConverter, updateHandler),
                    initialUpdate: initialUpdate)
        }
    }
    
    public
    typealias OnActionProcessed = (_ /*action*/: UFLAction) -> Void
    
    public
    typealias OnActionRejected = (_ /*action*/: UFLAction, _ /*error*/: Error) -> Void
    
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
                modelConverter: { $0 /*just return what we got as input*/ },
                updateHandler: { (_) in /*do nothing*/ })
    }
    
    public
    func unsubscribe(observer: AnyObject)
    {
        subscriptions.removeObject(forKey: observer)
    }
    
    public
    func submit(action: UFLAction)
    {
        self.submit(action, actionBlock: action.main)
    }
    
    //=== MARK: Private functions
    
    private
    func submit(_ action: UFLAction, actionBlock: @escaping UFLActionBlock)
    {
        OperationQueue
            .main
            .addOperation {
                
                // we add this action to queue async-ly,
                // to make sure it will be processed AFTER
                // current execution is completes,
                // that even allows from an Action handler
                // to submit another Action
                
                self.process(action, actionBlock: actionBlock)
        }
    }
    
    private
    func process(_ action: UFLAction, actionBlock: UFLActionBlock)
    {
        do
        {
            try actionBlock(self, state)(&state)
            
            //===
            
            action.onSuccess(dispatcher: self, state: state)
            
            //===
            
            notifySubscriptions(action: action)
            
            //===
            
            if
                let handler = onActionProcessed
            {
                handler(action)
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
                handler(action, error)
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
            notifySubscription(subscription: subscription, action: InitialUpdate())
        }
    }
    
    private
    func notifySubscriptions(action: UFLAction)
    {
        for key in subscriptions.keyEnumerator().allObjects as [AnyObject]
        {
            notifySubscription(
                subscription: subscriptions.object(forKey: key)!,
                action: action)
        }
    }
    
    private
    func notifySubscription(subscription: UFLSubscription, action: UFLAction)
    {
        if
            let subModel = subscription.modelConverter(state)
        {
            subscription
                .updateHandler(subModel, action)
        }
    }
}

//=== MARK: - ObjC compatibility

public
extension UFLDispatcher
{
    private
    enum Helper
    {
        static
        func name(ofAction action: UFLAction) -> String
        {
            return
                String(reflecting: type(of:action))
        }
    }
    
    @objc
    public
    func subscribeWithObserver(
        observer: AnyObject,
        onPrepare: @escaping (_ /*globalModel*/: AnyObject) -> AnyObject?,
        onUpdate: @escaping (_ /*state*/: AnyObject, _ /*actionName*/: String) -> Void)
    {
        prepareSubscription(observer: observer)
            .onConvertModel(onPrepare)
            .onUpdate({ (state, action) in
                
                onUpdate(state, Helper.name(ofAction: action))
            })
            .activate()
    }

    @objc
    public
    func subscribeWithObserver(
        observer: AnyObject,
        onUpdate: @escaping (_ /*state*/: AnyObject, _ /*actionName*/: String) -> Void)
    {
        prepareSubscription(observer: observer)
            .onConvertModel({ $0 as AnyObject })
            .onUpdate({ (state, action) in

                onUpdate(state, Helper.name(ofAction: action))
            })
            .activate()
    }
}
