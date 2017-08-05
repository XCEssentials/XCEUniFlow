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
enum NoMutation: MutationAnnotation { }

//===

public
enum UnspecifiedMutation: MutationAnnotation { } // maybe multiple mutations???

//===

public
extension Feature
{
    static
    func action(
        name: String = #function,
        body: @escaping (GlobalModel, Wrapped<Mutations<GlobalModel>>, @escaping Wrapped<ActionGetter>) throws -> Void
        ) -> Action
    {
        return Action(name: name, feature: Self.self) { model, submit in
            
            var updatedModel = model
            
            //===
            
            try body(model, { $0(&updatedModel) }, submit)
            
            //===
            
            return ({ $0 = updatedModel }, UnspecifiedMutation.self)
        }
    }
}
