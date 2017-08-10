import Foundation

//===

public
final
class Subscription
{
    typealias Identifier = ObjectIdentifier
    
    lazy
    var identifier: Identifier = Identifier(self)
    
    //===
    
    let notify: (Mutation, GlobalModel) -> Void
    
    //===
    
    init(_ notify: @escaping (Mutation, GlobalModel) -> Void)
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
        _ notifyNow: @escaping (GlobalModel) -> Void,
        _ notify: @escaping (Mutation, GlobalModel) -> Void
        ) -> Dispatcher.Proxy
    {
        DispatchQueue.main.async {
            
            notifyNow(self.dispatcher.model)
        }
        
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
        _ notify: @escaping (Mutation, GlobalModel) -> Void
        ) -> Dispatcher.Proxy
    {
        let subscription = Subscription(notify)
        dispatcher.subscriptions[subscription.identifier] = subscription
        
        //===
        
        if
            notifyNow
        {
            DispatchQueue.main.async {
                
                notify(NoMutation(), self.dispatcher.model)
            }
        }
        
        //===
        
        return Dispatcher.Proxy(
            for: dispatcher,
            subscription: subscription
        )
    }
    
    @discardableResult
    public
    func notifyNow(
        _ runOnce: @escaping (Mutation, GlobalModel) -> Void
        ) -> Dispatcher.Proxy
    {
        DispatchQueue.main.async {
            
            runOnce(NoMutation(), self.dispatcher.model)
        }
        
        return self
    }
}
