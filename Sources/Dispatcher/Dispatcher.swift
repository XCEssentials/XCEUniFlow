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
        
        //===
        
        init(_ dispatcher: Dispatcher)
        {
            self.dispatcher = dispatcher
        }
    }
    
    public
    lazy
    var proxy: Proxy = Proxy(self)
    
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
