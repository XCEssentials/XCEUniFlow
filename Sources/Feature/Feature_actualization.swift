import XCERequirement

//===

public
extension Feature
{
    static
    func actualization<S: FeatureState>(
        action name: String = #function,
        body: @escaping (S, Wrapped<Mutations<S>>, @escaping Wrapped<ActionGetter>) throws -> Void
        ) -> Action
        where Self == S.ParentFeature
    {
        return action(name) { model, mutate, submit in
            
            let currentState =
                
            try REQ.value("\(S.ParentFeature.name) is in \(S.self) state") {
                
                model ==> S.self
            }
            
            //===
            
            var buf = currentState
            
            try body(currentState, { $0(&buf) }, submit)
            
            //===
            
            mutate { $0 <== buf }
        }
    }
}
