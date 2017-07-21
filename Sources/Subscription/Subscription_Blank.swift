//public
//struct SubscriptionBlank
//{
//    let proxy: Dispatcher.Proxy
//    let initialUpdate: Bool
//    
//    //===
//    
//    public
//    func onConvert<SubState>(
//        _ cvt: @escaping (GlobalModel) -> SubState?
//        )
//        -> SubscriptionPending<SubState>
//    {
//        return SubscriptionPending(base: self, onConvert: cvt)
//    }
//    
//    public
//    func onUpdate(_ upd: @escaping (GlobalModel) -> Void)
//    {
//        dispatcher.add(
//            Subscription({ $0 }, upd),
//            initialUpdate
//        )
//    }
//}
