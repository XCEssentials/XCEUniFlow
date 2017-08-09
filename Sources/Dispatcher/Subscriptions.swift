public
final
class Subscription
{
    public
    typealias InitialNotification = (GlobalModel) -> Void
    
    public
    typealias Notification = (MutationsAnnotation, GlobalModel) -> Void
    
    //===

    typealias Identifier = ObjectIdentifier
    
    lazy
    var identifier: Identifier = Identifier(self)
    
    //===
    
    let notify: Notification
    
    //===
    
    init(_ notify: @escaping Notification)
    {
        self.notify = notify
    }
}

// MARK: Proxy extensions

public
extension Dispatcher.Proxy
{
    public
    func subscribe(
        _ notifyNow: Subscription.InitialNotification,
        _ notify: @escaping Subscription.Notification
        ) -> Dispatcher.Proxy
    {
        notifyNow(dispatcher.model)
        
        //===
        
        let subscription = Subscription(notify)
        dispatcher.subscriptions[subscription.identifier] = subscription
        
        //===
        
        return Dispatcher.Proxy(
            for: dispatcher,
            subscription: subscription
        )
    }
    
    public
    func subscribe(
        notifyNow: Bool = true,
        _ notify: @escaping Subscription.Notification
        ) -> Dispatcher.Proxy
    {
        let subscription = Subscription(notify)
        dispatcher.subscriptions[subscription.identifier] = subscription
        
        //===
        
        if
            notifyNow
        {
            notify(NoMutations(), dispatcher.model)
        }
        
        //===
        
        return Dispatcher.Proxy(
            for: dispatcher,
            subscription: subscription
        )
    }
    
    public
    func notifyNow(
        _ runOnce: Subscription.Notification
        )
    {
        runOnce(NoMutations(), dispatcher.model)
    }
}
