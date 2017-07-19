import Foundation

//===

public
final
class Dispatcher
{
    //=== MARK: Private members
    
    var model = GlobalModel()
    
    var subscriptions = NSMapTable<AnyObject, Subscription>(
        keyOptions: .weakMemory,
        valueOptions: .strongMemory
    )
    
    //===
    
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
    init() {}
}
