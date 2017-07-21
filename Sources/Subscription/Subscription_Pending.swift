public
struct SubscriptionPending<SubState>
{
    let base: SubscriptionBlank
    let onConvert: (GlobalModel) -> SubState?
    
    //===
    
    public
    func onUpdate(_ upd: @escaping (SubState) -> Void)
    {
        base.dispatcher.add(
            Subscription(base.observer, onConvert, upd),
            base.initialUpdate
        )
    }
}
