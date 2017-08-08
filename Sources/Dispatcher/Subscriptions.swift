public
final
class Subscription
{
    public
    typealias Body = (GlobalModel, MutationsAnnotation) -> Void
    
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
        updateNow: Bool = true,
        _ handler: @escaping Subscription.Body
        ) -> Dispatcher.Proxy
    {
        let subscription = Subscription(handler)
        dispatcher.subscriptions[subscription.identifier] = subscription
        
        //===
        
        if
            updateNow
        {
            handler(dispatcher.model, NoMutations())
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
        runOnce(dispatcher.model, NoMutations())
    }
}
