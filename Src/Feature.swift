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
    func initialization<UFLOutFS: SimpleState>(
        action name: String = #function,
        into targetState: UFLOutFS.Type
        ) -> Action
        where Self == UFLOutFS.UFLFeature
    {
        return
            initialization(action: name, into: targetState) { become, _ in
                    
                become { targetState.init() }
            }
    }
    
    //===
    
    static
    func initialization<UFLOutFS: FeatureState>(
        action name: String = #function,
        into _: UFLOutFS.Type,
        body: @escaping ((() -> UFLOutFS?) -> Void, @escaping ActionGetterWrapped) throws -> Void
        ) -> Action
        where Self == UFLOutFS.UFLFeature
    {
        return
            Action("\(self.name).\(name)") { globalModel, mutateGlobal, next in
                
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
    
    //===
    
    static
    func transition<UFLInFS: FeatureState, UFLOutFS: FeatureState>(
        action name: String = #function,
        from _: UFLInFS.Type,
        into _: UFLOutFS.Type,
        body: @escaping (UFLInFS, (() -> UFLOutFS) -> Void, @escaping ActionGetterWrapped) throws -> Void
        ) -> Action
        where Self == UFLInFS.UFLFeature, UFLInFS.UFLFeature == UFLOutFS.UFLFeature
    {
        return
            Action("\(self.name).\(name)") { globalModel, mutateGlobal, next in
                
                let current = try UFL.extract("\(UFLInFS.UFLFeature.name) is in \(UFLInFS.self) state") {
                    
                    globalModel ==> UFLInFS.self
                }
                
                //===
                
                var target: UFLOutFS?
                
                try body(current, { target = $0() }, next)
                
                //===
                
                try UFL.isNotNil("New state for feature \(UFLInFS.UFLFeature.name) is set") { target }
                
                //===
                
                mutateGlobal { $0 <== target }
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
        return
            transition(action: name, from: currentState, into: targetState) { _, become, _ in
                
                become { targetState.init() }
            }
    }
    
    //===
    
    static
    func actualization<UFLFS: FeatureState>(
        action name: String = #function,
        of _: UFLFS.Type,
        body: @escaping (UFLFS, (Mutations<UFLFS>) -> Void, @escaping ActionGetterWrapped) throws -> Void
        ) -> Action
        where Self == UFLFS.UFLFeature
    {
        return
            transition(action: name, from: UFLFS.self, into: UFLFS.self) { state, become, next in
                
                var buf = state
                
                try body(state, { $0(&buf) }, next)
                
                become { buf }
            }
    }
    
    //===
    
    static
    func deinitialization<UFLInFS: FeatureState>(
        action name: String = #function,
        from _: UFLInFS.Type,
        body: @escaping (UFLInFS, (() -> Bool) -> Void, @escaping ActionGetterWrapped) throws -> Void
        ) -> Action
        where Self == UFLInFS.UFLFeature
    {
        return
            Action("\(self.name).\(name)") { globalModel, mutateGlobal, next in
                
                let current = try UFL.extract("\(UFLInFS.UFLFeature.name) is in \(UFLInFS.self) state") {
                    
                    globalModel ==> UFLInFS.self
                }
                
                //===
                
                var shouldRemove = true
                
                try body(current, { shouldRemove = $0() }, next)
                
                //===
                
                if
                    shouldRemove
                {
                    mutateGlobal { $0 /== Self.self }
                }
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
        return deinitialization(from: currentState) { _, _, _ in }
    }
}

//===

public
protocol FeatureState
{
    associatedtype UFLFeature: Feature
}

//===

public
protocol SimpleState: FeatureState
{
    init()
}
