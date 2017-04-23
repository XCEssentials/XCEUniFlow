//
//  Feature.transition.swift
//  MKHUniFlow
//
//  Created by Maxim Khatskevich on 2/22/17.
//  Copyright © 2017 Maxim Khatskevich. All rights reserved.
//

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
        return Action("\(self.name).\(name)") { gm, mutate, next in
                
            let current = try REQ.value("\(UFLInFS.UFLFeature.name) is in \(UFLInFS.self) state") {
                
                gm ==> UFLInFS.self
            }
            
            //===
            
            var target: UFLOutFS?
            
            try body(current, { target = $0() }, next)
            
            //===
            
            try REQ.isNotNil("New state for feature \(UFLInFS.UFLFeature.name) is set") { target }
            
            //===
            
            mutate { $0 <== target }
        }
    }
    
    //===
    
    static
    func transition<UFLInFS: FeatureState, UFLOutFS: SimpleState>(
        action name: String = #function,
        from currentState: UFLInFS.Type,
        into targetState: UFLOutFS.Type,
        body: @escaping (@escaping ActionGetterWrapped) throws -> Void
        ) -> Action
        where Self == UFLInFS.UFLFeature, UFLInFS.UFLFeature == UFLOutFS.UFLFeature
    {
        return transition(action: name, from: currentState, into: targetState) { _, become, next in
            
            become { targetState.init() }
            
            //===
            
            try body(next)
        }
    }
    
    //===
    
    static
    func transition<UFLInFS: FeatureState, UFLOutFS: SimpleState>(
        action name: String = #function,
        from currentState: UFLInFS.Type,
        into targetState: UFLOutFS.Type
        ) -> Action
        where Self == UFLInFS.UFLFeature, UFLInFS.UFLFeature == UFLOutFS.UFLFeature
    {
        return transition(action: name, from: currentState, into: targetState) { _, become, _ in
                
            become { targetState.init() }
        }
    }
}
