import XCERequirement

//===

public
extension Feature
{
    static
    var actualization: ActualizationOf<Self>.Type
    {
        return ActualizationOf<Self>.self
    }
}

//===

public
enum ActualizationOf<F: Feature>
{
    public
    enum At<S: FeatureState> where S.ParentFeature == F { }
    // swiftlint:disable:previous type_name
}

//===

public
extension ActualizationOf.At
{
    static
    func via(
        action: String = #function,
        // currentState, mutate, submit
        body: @escaping (S, Wrapped<Mutations<S>>, @escaping Wrapped<ActionGetter>) throws -> Void
        ) -> Action
    {
        return Action(name: action, context: F.self) { model, submit in
            
            var state =
                
            try REQ.value("\(F.name) is in \(S.self) state") {
                
                model ==> S.self
            }
            
            //===
            
            try body(state, { $0(&state) }, submit)
            
            //===
            
            return ({ $0 <== state }, ActualizationOf<F>.self)
        }
    }
}
