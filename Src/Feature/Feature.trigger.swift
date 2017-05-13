//
//  Feature.trigger.swift
//  UniFlow
//
//  Created by Maxim Khatskevich on 5/8/17.
//
//

import Foundation

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
        return action(name) { gm, _, next in
            
            let state =
                
            try REQ.value("\(UFLFS.UFLFeature.name) is in \(UFLFS.self) state") {
                
                gm ==> UFLFS.self
            }
            
            //===
            
            try body(state, next)
        }
    }
    
    static
    func trigger(
        action name: String = #function,
        body: @escaping (GlobalModel, @escaping ActionGetterWrapped) throws -> Void
        ) -> Action
    {
        return action(name) { gm, _, next in
            
            try body(gm, next)
        }
    }
}
