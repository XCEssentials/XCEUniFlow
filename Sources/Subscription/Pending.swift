import Foundation

//===

public
struct SubscriptionPending<UFLSubState>
{
    let base: SubscriptionBlank
    let onConvert: (_: GlobalModel) -> UFLSubState?
    
    //===
    
    public
    func onUpdate(_ upd: @escaping (_: UFLSubState) -> Void)
    {
        base.dispatcher
            .register(
                base.observer,
                Subscription(onConvert, upd),
                base.initialUpdate)
    }
}
