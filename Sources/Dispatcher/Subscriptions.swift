public
final
class Subscription
{
    public
    typealias Body = (GlobalModel, DispatcherNotification.Type) -> Void
    
    //===

    typealias Identifier = ObjectIdentifier
    
    lazy
    var identifier: Identifier = Identifier(self)
    
    //===
    
    let body: Body
    
    //===
    
    init(_ body: @escaping Body)
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
        _ updateNow: Bool = true,
        _ handler: @escaping Subscription.Body
        ) -> Dispatcher.Proxy
    {
        let subscription = Subscription(handler)
        dispatcher.subscriptions[subscription.identifier] = subscription
        
        //===
        
        if
            updateNow
        {
            handler(dispatcher.model, InitialUpdate.self)
        }
        
        //===
        
        return Dispatcher.Proxy(
            for: dispatcher,
            subscription: subscription
        )
    }
    
    public
    func executeNow(
        _ runOnce: Subscription.Body
        )
    {
        runOnce(dispatcher.model, InitialUpdate.self)
    }
}
