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
typealias ActionBody = (
    _ model: GlobalModel,
    _ submit: @escaping Wrapped<ActionGetter>
    )
    throws -> (Mutations<GlobalModel>, MutationAnnotation.Type)?

public
typealias Wrapped<Value> = (Value) -> Void

public
typealias ActionGetter = () -> Action

public
typealias Mutations<Value> = (_: inout Value) -> Void

//===

public
typealias StateGetter<State: FeatureState> = () -> State
