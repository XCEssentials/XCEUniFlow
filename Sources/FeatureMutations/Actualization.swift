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
struct ActualizationOf<F: Feature>: GlobalMutationExt
{
    public
    struct In<S: FeatureState> where S.ParentFeature == F
    // swiftlint:disable:previous type_name
    {
        public
        let state: S
    }
    
    //===
    
    static
    var kind: FeatureMutationKind { return .update }
    
    let apply: (GlobalModel) -> GlobalModel
    
    //===
    
    public
    let state: FeatureRepresentation
    
    //===
    
    init<S: FeatureState>(in state: S) where S.ParentFeature == F
    {
        self.state = state
        self.apply = { $0.store(state) }
    }
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
        body: @escaping (S, Mutate<S>, @escaping SubmitAction) throws -> Void
        ) -> Action
    {
        return Action(scope, context, self) { model, submit in
            
            var state =
                
            try Require("\(S.ParentFeature.name) is in \(S.self) state").isNotNil(
                
                model >> S.self
            )
            
            //---
            
            try body(state, { state = $0 }, submit)
            
            //---
            
//            return ({ $0 << state }, ActualizationOf<F>(state: state))
//            return [ Store(state: state) ]
            return ActualizationOf(in: state)
        }
    }
}
