final
class Subscription
{
    typealias Identifier = ObjectIdentifier

    lazy
    var identifier: Identifier = Identifier(self)
    
    //===
    
    let onConvert: ((GlobalModel) -> Any?)?
    let onUpdate: (Any) -> Void

    //===

    init<SubState>(
        _ onConvert: @escaping (_: GlobalModel) -> SubState?,
        _ onUpdate: @escaping (_: SubState) -> Void
        )
    {
        self.onConvert = onConvert
        self.onUpdate = { ($0 as? SubState).map(onUpdate) }
    }
    
    init(
        _ onUpdate: @escaping (_: GlobalModel) -> Void
        )
    {
        self.onConvert = nil
        self.onUpdate = { ($0 as? GlobalModel).map(onUpdate) }
    }
    
    //===
    
    func execute(with model: GlobalModel)
    {
        if
            let cvt = onConvert
        {
            cvt(model).map(onUpdate)
        }
        else
        {
            onUpdate(model)
        }
    }
}
