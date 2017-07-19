extension Dispatcher
{
    func register(_ observer: AnyObject,
                  _ subscription: Subscription,
                  _ initialUpdate: Bool = true)
    {
        subscriptions.setObject(subscription, forKey: observer)
        
        //===
        
        if initialUpdate
        {
            notify(subscription)
        }
    }
    
    func notifySubscriptions()
    {
        subscriptions
            .objectEnumerator()?
            .allObjects
            .flatMap({ $0 as? Subscription })
            .forEach(notify)
    }
    
    func notify(_ subscription: Subscription)
    {
        subscription
            .onConvert(model)
            .map(subscription.onUpdate)
    }
}
