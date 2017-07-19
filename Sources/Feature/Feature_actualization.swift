import XCERequirement

//===

public
extension Feature
{
    static
    func actualization<UFLFS: FeatureState>(
        action name: String = #function,
        of _: UFLFS.Type,
        body: @escaping (UFLFS, (Mutations<UFLFS>) -> Void, @escaping ActionGetterWrapped) throws -> Void
        ) -> Action
        where Self == UFLFS.UFLFeature
    {
        return action(name) { model, mutate, next in
            
            let currentState =
                
            try REQ.value("\(UFLFS.UFLFeature.name) is in \(UFLFS.self) state") {
                
                model ==> UFLFS.self
            }
            
            //===
            
            var buf = currentState
            
            try body(currentState, { $0(&buf) }, next)
            
            //===
            
            mutate { $0 <== buf }
        }
    }
}
