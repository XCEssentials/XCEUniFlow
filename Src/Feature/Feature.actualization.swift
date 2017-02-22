//
//  Feature.actualization.swift
//  MKHUniFlow
//
//  Created by Maxim Khatskevich on 2/22/17.
//  Copyright © 2017 Maxim Khatskevich. All rights reserved.
//

import Foundation

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
        return transition(action: name, from: UFLFS.self, into: UFLFS.self) { state, become, next in
                
            var buf = state
            
            try body(state, { $0(&buf) }, next)
            
            become { buf }
        }
    }
}
