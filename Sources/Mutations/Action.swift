public
struct Action
{
    let name: String
    let context: Any.Type
    let body: ActionBody
    
    //===
    
    public
    var contextDescription: String { return String(reflecting: context) }
    
    public
    var fullName: String { return "\(contextDescription).\(name)" }
}

//===

public
typealias ActionBody = (
    _ model: GlobalModel,
    _ submit: @escaping Wrapped<ActionGetter>
    )
    throws -> (Mutations<GlobalModel>, ActionDescription.Type)?

public
typealias Wrapped<Value> = (Value) -> Void

public
typealias ActionGetter = () -> Action

public
typealias Mutations<Value> = (_: inout Value) -> Void

//===

public
typealias StateGetter<State: FeatureState> = () -> State
