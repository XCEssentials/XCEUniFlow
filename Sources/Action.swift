public
protocol Action
{
    var name: String { get }
    
    var body: ActionBody { get }
}

//===

public
struct GenericAction: Action
{
    public
    let name: String
    
    public
    let body: ActionBody
}
