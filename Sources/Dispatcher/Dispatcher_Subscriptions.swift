extension Dispatcher
{
    func subscribe(
        _ observer: AnyObject,
        updateNow: Bool = true
        ) -> SubscriptionBlank
    {
        return
            SubscriptionBlank(
                observer: observer,
                dispatcher: self,
                initialUpdate: updateNow)
    }
    
    func unsubscribe(_ observer: AnyObject)
    {
        subscriptions
            .removeObject(forKey: observer)
    }

    func register(_ observer: AnyObject,
                  _ subscription: Subscription,
                  _ initialUpdate: Bool = true)
    {
        subscriptions
            .setObject(subscription, forKey: observer)
        
        //===
        
        if initialUpdate
        {
            notify(subscription)
        }
    }
    
    func notifySubscriptions()
    {
        _ = subscriptions
            .objectEnumerator()?
            .allObjects
            .flatMap({ $0 as? Subscription })
            .map(notify)
    }
    
    func notify(_ subscription: Subscription)
    {
        subscription
            .onConvert(model)
            .map(subscription.onUpdate)
    }
}
