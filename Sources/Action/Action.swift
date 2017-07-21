public
struct Action
{
    let name: String
    let feature: Feature.Type
    let body: ActionBody
    
    //===
    
    public
    var fullName: String { return "\(feature.name).\(name)" }
}

//===

public
extension Feature
{
    static
    func action(name: String = #function, body: @escaping ActionBody) -> Action
    {
        return Action(name: name, feature: Self.self, body: body)
    }
}
