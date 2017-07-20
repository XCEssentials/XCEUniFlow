public
struct GenericAction: Action
{
    public
    let name: String
    
    public
    let body: ActionBody
}

//===

public
extension GenericAction
{
    init(
        action: String = #function,
        body: @escaping ActionBody
        )
    {
        self.name = action
        self.body = body
    }
}
