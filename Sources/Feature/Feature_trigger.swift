import XCERequirement

//===

public
extension Feature
{
    static
    func trigger<UFLFS: FeatureState>(
        action name: String = #function,
        on _: UFLFS.Type,
        body: @escaping (UFLFS, @escaping Wrapped<ActionGetter>) throws -> Void
        ) -> Action
        where Self == UFLFS.ParentFeature
    {
        return action(name) { model, _, submit in
            
            let currentState =
                
            try REQ.value("\(UFLFS.ParentFeature.name) is in \(UFLFS.self) state") {
                
                model ==> UFLFS.self
            }
            
            //===
            
            try body(currentState, submit)
        }
    }
    
    static
    func trigger(
        action name: String = #function,
        body: @escaping (GlobalModel, @escaping Wrapped<ActionGetter>) throws -> Void
        ) -> Action
    {
        return action(name) { model, _, submit in
            
            try body(model, submit)
        }
    }
}
