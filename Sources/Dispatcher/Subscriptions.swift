public
typealias InitialConfiguration = (GlobalModel) -> Void

public
typealias SubscriptionBody = (GlobalModel, ActionDescription.Type) -> Void

//===

final
class Subscription
{
    typealias Identifier = ObjectIdentifier
    
    lazy
    var identifier: Identifier = Identifier(self)
    
    //===
    
    let body: SubscriptionBody
    
    //===
    
    init(_ body: @escaping SubscriptionBody)
    {
        self.body = body
    }
}

// MARK: Proxy extensions

public
extension Dispatcher.Proxy
{
    public
    func subscribe(
        _ runNow: InitialConfiguration,
        _ onUpdate: @escaping SubscriptionBody
        ) -> Dispatcher.Proxy
    {
        runNow(dispatcher.model)
        
        //===
        
        let subscription = Subscription(onUpdate)
        dispatcher.subscriptions[subscription.identifier] = subscription
        
        //===
        
        return Dispatcher.Proxy(
            for: dispatcher,
            subscription: subscription
        )
    }
    
    public
    func subscribe(
        _ onUpdate: @escaping SubscriptionBody
        ) -> Dispatcher.Proxy
    {
        let subscription = Subscription(onUpdate)
        dispatcher.subscriptions[subscription.identifier] = subscription
        
        //===
        
        return Dispatcher.Proxy(
            for: dispatcher,
            subscription: subscription
        )
    }
}
