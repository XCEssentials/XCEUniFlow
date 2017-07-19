import Foundation

//===

public
final
class Dispatcher
{
    //=== MARK: Private members
    
    var model = GlobalModel()
    
    var subscriptions =
        NSMapTable<AnyObject, Subscription>(
            keyOptions: .weakMemory,
            valueOptions: .strongMemory
        )
    
    //=== MARK: Public members
    
    public
    var onReject: ((_ actionId: String, _: Error) -> Void)?
    
    //=== Initializer
    
    public
    init() {}
}
