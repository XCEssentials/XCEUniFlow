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
struct ActualizationOf<F: Feature>
{
    public
    struct In<S: FeatureState> where S.ParentFeature == F
    // swiftlint:disable:previous type_name
    {
        public
        let state: S
    }
    
    //===
    
    public
    let state: Any
}

public
typealias ActualizationIn<S: FeatureState> = ActualizationOf<S.ParentFeature>.In<S>

//===

public
extension ActualizationOf.In
{
    static
    func via(
        scope: String = #file,
        context: String = #function,
        // currentState, mutate, submit
        body: @escaping (S, Wrapped<Mutations<S>>, @escaping Wrapped<ActionGetter>) throws -> Void
        ) -> Action
    {
        return Action(scope, context, self) { model, submit in
            
            var state =
                
            try REQ.value("\(F.name) is in \(S.self) state") {
                
                model >> S.self
            }
            
            //===
            
            try body(state, { $0(&state) }, submit)
            
            //===
            
            return ({ $0 << state }, ActualizationOf<F>(state: state))
        }
    }
}
