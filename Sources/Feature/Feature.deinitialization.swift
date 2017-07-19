//
//  Feature.deinitialization.swift
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
    func deinitialization<UFLInFS: FeatureState>(
        action name: String = #function,
        from _: UFLInFS.Type,
        body: @escaping (UFLInFS, (() -> Bool) -> Void, @escaping ActionGetterWrapped) throws -> Void
        ) -> Action
        where Self == UFLInFS.UFLFeature
    {
        return action(name) { gm, mutate, next in
                
            let currentState =
                
            try REQ.value("\(UFLInFS.UFLFeature.name) is in \(UFLInFS.self) state") {
                
                gm ==> UFLInFS.self
            }
            
            //===
            
            var shouldProceed = true
            
            try body(currentState, { shouldProceed = $0() }, next)
            
            //===
            
            if
                shouldProceed
            {
                mutate{ $0 /== Self.self }
            }
        }
    }
    
    //===
    
    static
    func deinitialization<UFLInFS: FeatureState>(
        action name: String = #function,
        from _: UFLInFS.Type,
        body: @escaping (@escaping ActionGetterWrapped) throws -> Void
        ) -> Action
        where Self == UFLInFS.UFLFeature
    {
        return action(name) { gm, mutate, next in
            
            try REQ.isNotNil("\(UFLInFS.UFLFeature.name) is in \(UFLInFS.self) state") {
                
                gm ==> UFLInFS.self
            }
            
            //===
            
            mutate{ $0 /== Self.self }
            
            //===
            
            try body(next)
        }
    }
    
    //===
    
    static
    func deinitialization<UFLInFS: FeatureState>(
        action name: String = #function,
        from _: UFLInFS.Type
        ) -> Action
        where Self == UFLInFS.UFLFeature
    {
        return action(name) { gm, mutate, _ in
            
            try REQ.isNotNil("\(UFLInFS.UFLFeature.name) is in \(UFLInFS.self) state") {
                
                gm ==> UFLInFS.self
            }
            
            //===
            
            mutate{ $0 /== Self.self }
        }
    }
}
