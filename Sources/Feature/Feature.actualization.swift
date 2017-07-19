//
//  Feature.actualization.swift
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
    func actualization<UFLFS: FeatureState>(
        action name: String = #function,
        of _: UFLFS.Type,
        body: @escaping (UFLFS, (Mutations<UFLFS>) -> Void, @escaping ActionGetterWrapped) throws -> Void
        ) -> Action
        where Self == UFLFS.UFLFeature
    {
        return action(name) { gm, mutate, next in
            
            let currentState =
                
            try REQ.value("\(UFLFS.UFLFeature.name) is in \(UFLFS.self) state") {
                
                gm ==> UFLFS.self
            }
            
            //===
            
            var buf = currentState
            
            try body(currentState, { $0(&buf) }, next)
            
            //===
            
            mutate { $0 <== buf }
        }
    }
}
