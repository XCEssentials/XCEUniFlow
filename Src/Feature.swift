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
    func initiation<UFLOutFS: FeatureState>(
        _ name: String = #function,
        to _: UFLOutFS.Type,
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
    
    static
    func transition<UFLInFS: FeatureState, UFLOutFS: FeatureState>(
        _ name: String = #function,
        from _: UFLInFS.Type,
        to _: UFLOutFS.Type,
        _ body: @escaping (UFLInFS, (() -> UFLOutFS) -> Void, @escaping ActionGetterWrapped) throws -> Void
        ) -> Action
        where Self == UFLInFS.UFLFeature, UFLInFS.UFLFeature == UFLOutFS.UFLFeature
    {
        return
            Action(name: "\(self).\(name)") { globalModel, mutateGlobal, next in
                
                let from = try UFL.extract("\(UFLInFS.UFLFeature.name) is in \(UFLInFS.self) state") {
                    
                    globalModel ==> UFLInFS.self
                }
                
                //===
                
                var to: UFLOutFS?
                
                try body(from, { to = $0() }, next)
                
                //===
                
                try UFL.isNotNil("New state for feature \(UFLInFS.UFLFeature.name) is set") { to }
                
                //===
                
                mutateGlobal { $0 <== to }
        }
    }
    
    static
    func actualization<UFLFS: FeatureState>(
        _ name: String = #function,
        current _: UFLFS.Type,
        _ body: @escaping (UFLFS, (Mutations<UFLFS>) -> Void, @escaping ActionGetterWrapped) throws -> Void
        ) -> Action
        where Self == UFLFS.UFLFeature
    {
        return
            transition(from: UFLFS.self, to: UFLFS.self) { state, become, next in
                
                var buf = state
                
                try body(state, { $0(&buf) }, next)
                
                become { buf }
            }
    }
    
    static
    func deinitiation<UFLInFS: FeatureState>(
        _ name: String = #function,
        from _: UFLInFS.Type,
        _ body: @escaping (UFLInFS, (() -> Bool) -> Void, @escaping ActionGetterWrapped) throws -> Void
        ) -> Action
        where Self == UFLInFS.UFLFeature
    {
        return
            Action(name: "\(self).\(name)") { globalModel, mutateGlobal, next in
                
                let state = try UFL.extract("\(UFLInFS.UFLFeature.name) is in \(UFLInFS.self) state") {
                    
                    globalModel ==> UFLInFS.self
                }
                
                //===
                
                var shouldRemove = true
                
                try body(state, { shouldRemove = $0() }, next)
                
                //===
                
                if
                    shouldRemove
                {
                    mutateGlobal { $0 /== Self.self }
                }
        }
    }
}

//===

public
protocol FeatureState
{
    associatedtype UFLFeature: Feature
}
