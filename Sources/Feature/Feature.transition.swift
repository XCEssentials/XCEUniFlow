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
        return action(name) { gm, mutate, next in
                
            let currentState =
                
            try REQ.value("\(UFLInFS.UFLFeature.name) is in \(UFLInFS.self) state") {
                
                gm ==> UFLInFS.self
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
        return action(name) { gm, mutate, next in
            
            try REQ.isNotNil("\(UFLInFS.UFLFeature.name) is in \(UFLInFS.self) state") {
                
                gm ==> UFLInFS.self
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
        return action(name) { gm, mutate, _ in
            
            try REQ.isNotNil("\(UFLInFS.UFLFeature.name) is in \(UFLInFS.self) state") {
                
                gm ==> UFLInFS.self
            }
            
            //===
            
            mutate { $0 <== UFLOutFS.init() }
        }
    }
}
