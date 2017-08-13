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
        
        //===
        
        init(for dispatcher: Dispatcher)
        {
            self.dispatcher = dispatcher
        }
    }
    
    //=== MARK: Public members
    
    public
    lazy
    var proxy: Proxy = Proxy(for: self)
    
    public
    var onDidProcessAction: ((_ action: Action) -> Void)?
    
    public
    var onDidRejectAction: ((_ action: Action, _: Error) -> Void)?
    
    //=== Initializer
    
    public
    init(defaultReporting: DefaultReporting = .none)
    {
        switch defaultReporting
        {
            case .short:
                enableShortDefaultReporting()
            
            case .verbose:
                enableVerboseDefaultReporting()
            
            default:
                break
        }
    }
}
