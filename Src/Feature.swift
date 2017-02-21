//
//  Feature.swift
//  MKHUniFlow
//
//  Created by Maxim Khatskevich on 2/20/17.
//  Copyright © 2017 Maxim Khatskevich. All rights reserved.
//

import Foundation

//===

public
protocol Feature: ActionContext {}

//===

public
extension Feature
{
    static
    var name: String { return String(reflecting: Self.self) }
}

//===

public
extension Feature
{
    static
    func transition<UFLInFS: FeatureState, UFLOutFS: FeatureState>(
        _ name: String = #function,
        _ body: @escaping (UFLInFS?, (() -> UFLOutFS?) -> Void, @escaping ActionGetterWrapped) throws -> Void
        ) -> Action
        where Self == UFLInFS.UFLFeature, UFLInFS.UFLFeature == UFLOutFS.UFLFeature
    {
        return
            Action(name: "\(self).\(name)") { globalModel, mutateGlobal, next in
                
                let currentState = globalModel ==> UFLInFS.self
                
                var newState: UFLOutFS?
                
                //===
                
                try body(currentState, { newState = $0() }, next)
                
                //===
                
                mutateGlobal { $0 <== newState }
            }
    }
    
    
    static
    func initiation<UFLOutFS: FeatureState>(
        _ name: String = #function,
        _ body: @escaping ((() -> UFLOutFS?) -> Void, @escaping ActionGetterWrapped) throws -> Void
        ) -> Action
        where Self == UFLOutFS.UFLFeature
    {
        return
            Action(name: "\(self).\(name)") { globalModel, mutateGlobal, next in
                
                try UFL.isNil("\(UFLOutFS.UFLFeature.name) is NOT initialized yet") {
                    
                    globalModel ==> UFLOutFS.UFLFeature.self
                }
                
                //===
                
                var newState: UFLOutFS?
                
                //===
                
                try body({ newState = $0() }, next)
                
                //===
                
                mutateGlobal { $0 <== newState }
        }
    }
}

//===

public
protocol FeatureState
{
    associatedtype UFLFeature: Feature
}
