import XCERequirement

//===

public
extension Feature
{
    static
    func deinitialization<S: FeatureState>(
        action name: String = #function,
        body: @escaping (S, @escaping Wrapped<ActionGetter>) throws -> Void
        ) -> Action
        where Self == S.ParentFeature
    {
        return action(name) { model, mutate, next in
                
            let currentState =
                
            try REQ.value("\(S.ParentFeature.name) is in \(S.self) state") {
                
                model ==> S.self
            }
            
            //===
            
            try body(currentState, next)
            
            //===
            
            mutate{ $0 /== Self.self }
        }
    }
    
    static
    func deinitialization<S: FeatureState>(
        action name: String = #function,
        from _: S.Type
        ) -> Action
        where Self == S.ParentFeature
    {
        return action(name) { model, mutate, _ in
            
            try REQ.isNotNil("\(S.ParentFeature.name) is in \(S.self) state") {
                
                model ==> S.self
            }
            
            //===
            
            mutate{ $0 /== Self.self }
        }
    }
}
