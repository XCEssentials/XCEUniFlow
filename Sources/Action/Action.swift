public
struct Action
{
    public
    let name: String
    
    // internal
    let body: ActionBody
    
    //===
    
    // internal
    init(_ name: String, _ body: @escaping ActionBody)
    {
        self.name = name
        self.body = body
    }
}
