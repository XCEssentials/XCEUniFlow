import XCERequirement

//===

public
struct ActualizationOf<S: FeatureState>: Action
{
    public
    let name: String
    
    public
    let body: ActionBody
}

//===

public
extension ActualizationOf
{
    init(
        action: String = #function,
        body: @escaping (S, Wrapped<Mutations<S>>, @escaping Wrapped<ActionGetter>) throws -> Void
        )
    {
        self.name = action
        
        self.body = { model, mutate, submit in
            
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
