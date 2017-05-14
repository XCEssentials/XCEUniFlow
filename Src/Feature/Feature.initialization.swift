//
//  Feature.initialization.swift
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
    func initialization<UFLOutFS: FeatureState>(
        action name: String = #function,
        into _: UFLOutFS.Type,
        body: @escaping ((() -> UFLOutFS?) -> Void, @escaping ActionGetterWrapped) throws -> Void
        ) -> Action
        where Self == UFLOutFS.UFLFeature
    {
        return action(name) { gm, mutate, next in
                
            try REQ.isNil("\(UFLOutFS.UFLFeature.name) is NOT initialized yet") {
                
                gm ==> UFLOutFS.UFLFeature.self
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
        return action(name) { gm, mutate, next in
            
            try REQ.isNil("\(UFLOutFS.UFLFeature.name) is NOT initialized yet") {
                
                gm ==> UFLOutFS.UFLFeature.self
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
        return action(name) { gm, mutate, _ in
            
            try REQ.isNil("\(UFLOutFS.UFLFeature.name) is NOT initialized yet") {
                
                gm ==> UFLOutFS.UFLFeature.self
            }
            
            //===
            
            mutate { $0 <== UFLOutFS.init() }
        }
    }
}
