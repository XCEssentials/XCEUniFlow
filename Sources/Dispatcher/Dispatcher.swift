import Foundation

//===

public
final
class Dispatcher
{
    //=== MARK: Private members
    
    var model = GlobalModel()
    
    var subscriptions: [Subscription.Identifier: Subscription] = [:]
    
    //=== MARK: Nested public types
    
    public
    final
    class Proxy
    {
        //  https://en.wikipedia.org/wiki/Proxy_pattern
        
        let dispatcher: Dispatcher
        
        weak
        var subscription: Subscription?
        
        //===
        
        init(
            for dispatcher: Dispatcher,
            subscription: Subscription? = nil
            )
        {
            self.dispatcher = dispatcher
            self.subscription = subscription
        }
        
        deinit
        {
            if
                let subscription = subscription
            {
                dispatcher.subscriptions[subscription.identifier] = nil
            }
        }
    }
    
    //=== MARK: Public members
    
    public
    lazy
    var proxy: Proxy = Proxy(for: self)
    
    public
    var onDidProcessAction: ((_ action: String, _ context: String) -> Void)?
    
    public
    var onDidRejectAction: ((_ action: String, _ context: String, _: Error) -> Void)?
    
    //=== Initializer
    
    public
    init(defaultReporting: Bool = false)
    {
        if defaultReporting { enableDefaultReporting() }
    }
}
