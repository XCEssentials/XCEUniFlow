public
final
class Subscription
{
    typealias Identifier = ObjectIdentifier
    
    lazy
    var identifier: Identifier = Identifier(self)
    
    //===
    
    let notify: (MutationsAnnotation, GlobalModel) -> Void
    
    //===
    
    init(_ notify: @escaping (MutationsAnnotation, GlobalModel) -> Void)
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
        _ notifyNow: (GlobalModel) -> Void,
        _ notify: @escaping (MutationsAnnotation, GlobalModel) -> Void
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
        _ notify: @escaping (MutationsAnnotation, GlobalModel) -> Void
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
        _ runOnce: (MutationsAnnotation, GlobalModel) -> Void
        )
    {
        runOnce(NoMutations(), dispatcher.model)
    }
}
