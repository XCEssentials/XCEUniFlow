public
extension Dispatcher.Proxy
{
    public
    func subscribe(
        _ observer: AnyObject,
        updateNow: Bool = true
        ) -> SubscriptionBlank
    {
        return SubscriptionBlank(
            observer: observer,
            dispatcher: dispatcher,
            initialUpdate: updateNow
        )
    }
    
    public
    func unsubscribe(_ observer: AnyObject)
    {
        dispatcher.subscriptions.removeValue(
            forKey: Subscription.identifier(for: observer)
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
        
        if initialUpdate
        {
            notify(subscription)
        }
    }
    
    func notifySubscriptions()
    {
        subscriptions
            .map{ $0.value }
            .forEach(notify)
    }
    
    func notify(_ subscription: Subscription)
    {
        subscription
            .onConvert(model)
            .map(subscription.onUpdate)
    }
}
