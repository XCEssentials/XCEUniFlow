public
extension Dispatcher.Proxy
{
    public
    func subscribe(
        updateNow: Bool = true,
        onUpdate: @escaping (GlobalModel) -> Void
        ) -> Dispatcher.Proxy
    {
        let subscription = Subscription(onUpdate)
        
        //===
        
        dispatcher.add(subscription, updateNow)
        
        //===
        
        return Dispatcher.Proxy(
            for: dispatcher,
            subscription: subscription
        )
    }
    
    public
    func subscribe<SubState>(
        updateNow: Bool = true,
        onConvert: @escaping (GlobalModel) -> SubState?,
        onUpdate: @escaping (SubState) -> Void
        ) -> Dispatcher.Proxy
    {
        let subscription = Subscription(onConvert, onUpdate)
        
        //===
        
        dispatcher.add(subscription, updateNow)
        
        //===
        
        return Dispatcher.Proxy(
            for: dispatcher,
            subscription: subscription
        )
    }
}

//===

extension Dispatcher
{
    func add(
        _ subscription: Subscription,
        _ initialUpdate: Bool = true
        )
    {
        subscriptions[subscription.identifier] = subscription
        
        //===
        
        if
            initialUpdate
        {
            subscription.execute(with: model)
        }
    }
}
