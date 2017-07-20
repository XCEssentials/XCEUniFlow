import XCERequirement

//===

public
extension Feature
{
    static
    func transition<UFLInFS: FeatureState, UFLOutFS: FeatureState>(
        action name: String = #function,
        from _: UFLInFS.Type,
        into _: UFLOutFS.Type,
        body: @escaping (UFLInFS, (() -> UFLOutFS) -> Void, @escaping Wrapped<ActionGetter>) throws -> Void
        ) -> Action
        where Self == UFLInFS.ParentFeature, UFLInFS.ParentFeature == UFLOutFS.ParentFeature
    {
        return action(name) { model, mutate, submit in
                
            let currentState =
                
            try REQ.value("\(UFLInFS.ParentFeature.name) is in \(UFLInFS.self) state") {
                
                model ==> UFLInFS.self
            }
            
            //===
            
            var newState: UFLOutFS?
            
            try body(currentState, { newState = $0() }, submit)
            
            //===
            
            try REQ.isNotNil("New state for \(UFLInFS.ParentFeature.name) is set") {
                
                newState
            }
            
            //===
            
            mutate { $0 <== newState }
        }
    }
    
    //===
    
    static
    func transition<UFLInFS: FeatureState, UFLOutFS: SimpleState>(
        action name: String = #function,
        from _: UFLInFS.Type,
        into _: UFLOutFS.Type,
        body: @escaping (@escaping Wrapped<ActionGetter>) throws -> Void
        ) -> Action
        where Self == UFLInFS.ParentFeature, UFLInFS.ParentFeature == UFLOutFS.ParentFeature
    {
        return action(name) { model, mutate, submit in
            
            try REQ.isNotNil("\(UFLInFS.ParentFeature.name) is in \(UFLInFS.self) state") {
                
                model ==> UFLInFS.self
            }
            
            //===
            
            mutate { $0 <== UFLOutFS.init() }
            
            //===
            
            try body(submit)
        }
    }
    
    //===
    
    static
    func transition<UFLInFS: FeatureState, UFLOutFS: SimpleState>(
        action name: String = #function,
        from _: UFLInFS.Type,
        into _: UFLOutFS.Type
        ) -> Action
        where Self == UFLInFS.ParentFeature, UFLInFS.ParentFeature == UFLOutFS.ParentFeature
    {
        return action(name) { model, mutate, _ in
            
            try REQ.isNotNil("\(UFLInFS.ParentFeature.name) is in \(UFLInFS.self) state") {
                
                model ==> UFLInFS.self
            }
            
            //===
            
            mutate { $0 <== UFLOutFS.init() }
        }
    }
}
