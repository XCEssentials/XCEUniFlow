import XCERequirement

//===

public
extension Feature
{
    static
    func trigger<UFLFS: FeatureState>(
        action name: String = #function,
        on _: UFLFS.Type,
        body: @escaping (UFLFS, @escaping ActionGetterWrapped) throws -> Void
        ) -> Action
        where Self == UFLFS.UFLFeature
    {
        return action(name) { model, _, next in
            
            let currentState =
                
            try REQ.value("\(UFLFS.UFLFeature.name) is in \(UFLFS.self) state") {
                
                model ==> UFLFS.self
            }
            
            //===
            
            try body(currentState, next)
        }
    }
    
    static
    func trigger(
        action name: String = #function,
        body: @escaping (GlobalModel, @escaping ActionGetterWrapped) throws -> Void
        ) -> Action
    {
        return action(name) { model, _, next in
            
            try body(model, next)
        }
    }
}
