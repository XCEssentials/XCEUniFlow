public
struct SubscriptionBlank
{
    let observer: AnyObject
    let dispatcher: Dispatcher
    let initialUpdate: Bool
    
    //===
    
    public
    func onConvert<UFLSubState>(
        _ cvt: @escaping (_: GlobalModel) -> UFLSubState?
        )
        -> SubscriptionPending<UFLSubState>
    {
        return SubscriptionPending(base: self, onConvert: cvt)
    }
    
    public
    func onUpdate(_ upd: @escaping (_: GlobalModel) -> Void)
    {
        dispatcher
            .register(
                observer,
                Subscription({ $0 }, upd),
                initialUpdate)
    }
}
