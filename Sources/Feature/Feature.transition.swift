import Foundation

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
        body: @escaping (UFLInFS, (() -> UFLOutFS) -> Void, @escaping ActionGetterWrapped) throws -> Void
        ) -> Action
        where Self == UFLInFS.UFLFeature, UFLInFS.UFLFeature == UFLOutFS.UFLFeature
    {
        return action(name) { model, mutate, next in
                
            let currentState =
                
            try REQ.value("\(UFLInFS.UFLFeature.name) is in \(UFLInFS.self) state") {
                
                model ==> UFLInFS.self
            }
            
            //===
            
            var newState: UFLOutFS?
            
            try body(currentState, { newState = $0() }, next)
            
            //===
            
            try REQ.isNotNil("New state for \(UFLInFS.UFLFeature.name) is set") {
                
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
        body: @escaping (@escaping ActionGetterWrapped) throws -> Void
        ) -> Action
        where Self == UFLInFS.UFLFeature, UFLInFS.UFLFeature == UFLOutFS.UFLFeature
    {
        return action(name) { model, mutate, next in
            
            try REQ.isNotNil("\(UFLInFS.UFLFeature.name) is in \(UFLInFS.self) state") {
                
                model ==> UFLInFS.self
            }
            
            //===
            
            mutate { $0 <== UFLOutFS.init() }
            
            //===
            
            try body(next)
        }
    }
    
    //===
    
    static
    func transition<UFLInFS: FeatureState, UFLOutFS: SimpleState>(
        action name: String = #function,
        from _: UFLInFS.Type,
        into _: UFLOutFS.Type
        ) -> Action
        where Self == UFLInFS.UFLFeature, UFLInFS.UFLFeature == UFLOutFS.UFLFeature
    {
        return action(name) { model, mutate, _ in
            
            try REQ.isNotNil("\(UFLInFS.UFLFeature.name) is in \(UFLInFS.self) state") {
                
                model ==> UFLInFS.self
            }
            
            //===
            
            mutate { $0 <== UFLOutFS.init() }
        }
    }
}
