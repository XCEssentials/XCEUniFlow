import Foundation

import XCERequirement

//===

public
extension Feature
{
    static
    func initialization<UFLOutFS: FeatureState>(
        action name: String = #function,
        into _: UFLOutFS.Type,
        body: @escaping ((() -> UFLOutFS?) -> Void, @escaping ActionGetterWrapped) throws -> Void
        ) -> Action
        where Self == UFLOutFS.UFLFeature
    {
        return action(name) { model, mutate, next in
                
            try REQ.isNil("\(UFLOutFS.UFLFeature.name) is NOT initialized yet") {
                
                model ==> UFLOutFS.UFLFeature.self
            }
            
            //===
            
            var newState: UFLOutFS?
            
            //===
            
            try body({ newState = $0() }, next)
            
            //===
            
            try REQ.isNotNil("New state for \(UFLOutFS.UFLFeature.name) is set") {
                
                newState
            }
            
            //===
            
            mutate { $0 <== newState }
        }
    }
    
    //===
    
    static
    func initialization<UFLOutFS: SimpleState>(
        action name: String = #function,
        into _: UFLOutFS.Type,
        body: @escaping (@escaping ActionGetterWrapped) throws -> Void
        ) -> Action
        where Self == UFLOutFS.UFLFeature
    {
        return action(name) { model, mutate, next in
            
            try REQ.isNil("\(UFLOutFS.UFLFeature.name) is NOT initialized yet") {
                
                model ==> UFLOutFS.UFLFeature.self
            }
            
            //===
            
            mutate { $0 <== UFLOutFS.init() }
            
            //===
            
            try body(next)
        }
    }
    
    //===
    
    static
    func initialization<UFLOutFS: SimpleState>(
        action name: String = #function,
        into _: UFLOutFS.Type
        ) -> Action
        where Self == UFLOutFS.UFLFeature
    {
        return action(name) { model, mutate, _ in
            
            try REQ.isNil("\(UFLOutFS.UFLFeature.name) is NOT initialized yet") {
                
                model ==> UFLOutFS.UFLFeature.self
            }
            
            //===
            
            mutate { $0 <== UFLOutFS.init() }
        }
    }
}
