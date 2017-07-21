struct Subscription
{
    typealias Identifier = ObjectIdentifier
    
    let identifier: Identifier
    let observer: AnyObject
    let onConvert: (GlobalModel) -> Any?
    let onUpdate: (Any) -> Void

    //===

    init<SubState>(
        _ observer: AnyObject,
        _ onConvert: @escaping (_: GlobalModel) -> SubState?,
        _ onUpdate: @escaping (_: SubState) -> Void
        )
    {
        self.identifier = Subscription.identifier(for: observer)
        self.observer = observer
        self.onConvert = onConvert
        self.onUpdate = { ($0 as? SubState).map(onUpdate) }
    }
    
    //===
    
    static
    func identifier(for observer: AnyObject) -> Identifier
    {
        return Identifier(observer)
    }
}
