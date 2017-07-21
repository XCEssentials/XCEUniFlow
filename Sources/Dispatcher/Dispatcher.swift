import Foundation

//===

public
final
class Dispatcher
{
    //=== MARK: Private members
    
    var model = GlobalModel()
    
    var subscriptions: [Subscription.Identifier: Subscription] = [:]
    
    //===
    
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
                dispatcher
                    .subscriptions
                    .removeValue(forKey: subscription.identifier)
            }
        }
    }
    
    public
    lazy
    var proxy: Proxy = Proxy(for: self)
    
    //=== MARK: Public members
    
    public
    var onDidProcessAction: ((_ actionId: String) -> Void)?
    
    public
    var onDidRejectAction: ((_ actionId: String, _: Error) -> Void)?
    
    //=== Initializer
    
    public
    init(defaultReporting: Bool = false)
    {
        if
            defaultReporting
        {
            self.onDidProcessAction = {
                
                print("XCEUniFlow: [+] \($0) PROCESSED")
            }
            
            self.onDidRejectAction = {
                
                print("XCEUniFlow: [-] \($0) REJECTED, error: \($1)")
            }
        }
    }
}
