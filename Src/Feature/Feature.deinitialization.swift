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
        return Action("\(self.name).\(name)") { gm, mutate, next in
                
            let current = try REQ.value("\(UFLInFS.UFLFeature.name) is in \(UFLInFS.self) state") {
                
                gm ==> UFLInFS.self
            }
            
            //===
            
            var shouldProceed = true
            
            try body(current, { shouldProceed = $0() }, next)
            
            //===
            
            if
                shouldProceed
            {
                mutate { $0 /== Self.self }
            }
        }
    }
    
    //===
    
    static
    func deinitialization<UFLInFS: FeatureState>(
        action name: String = #function,
        from currentState: UFLInFS.Type,
        body: @escaping (@escaping ActionGetterWrapped) throws -> Void
        ) -> Action
        where Self == UFLInFS.UFLFeature
    {
        return deinitialization(action: name, from: currentState) { _, _, next in
        
            try body(next)
        }
    }
    
    //===
    
    static
    func deinitialization<UFLInFS: FeatureState>(
        action name: String = #function,
        from currentState: UFLInFS.Type
        ) -> Action
        where Self == UFLInFS.UFLFeature
    {
        return deinitialization(action: name, from: currentState) { _, _, _ in }
    }
}
