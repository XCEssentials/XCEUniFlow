//
//  Feature.trigger.swift
//  UniFlow
//
//  Created by Maxim Khatskevich on 5/8/17.
//
//

import Foundation

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
        return transition(action: name, from: UFLFS.self, into: UFLFS.self) { state, _, next in
            
            try body(state, next)
        }
    }
    
    static
    func trigger(
        action name: String = #function,
        body: @escaping (GlobalModel, @escaping ActionGetterWrapped) throws -> Void
        ) -> Action
    {
        return action(name) { state, _, next in
            
            try body(state, next)
        }
    }
}
