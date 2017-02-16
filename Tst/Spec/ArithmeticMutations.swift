//
//  ArithmeticMutations.swift
//  MKHUniFlow
//
//  Created by Maxim Khatskevich on 1/15/17.
//  Copyright © 2017 Maxim Khatskevich. All rights reserved.
//

import Foundation

import MKHUniFlow

//===

enum ArithmeticMutations: Feature
{
    static
    func doTheChanges() -> Action<GM>
    {
        return action { _, submit, _ in
            
            submit { ArithmeticMutations.setExplicit(value: 10) }
            submit { ArithmeticMutations.incFive() }
        }
    }
    
    static
    func setExplicit(value: Int) -> Action<GM>
    {
        return action { model, _, mutate in
            
            // you have to check at least one precondition to
            // definitely avoid doing the same action twice:
            
            // also you need to put at least something before
            // actually returning mutation code
            // to be able to use short closure notation
            // (without explicit input parameters type declaration) and
            // not getting the "parameter may not have 'var' specifier"
            // LOL Xcode bug, I guess...
            
            try UFL.verify("The model.v is not equal to desired new value") { model.v != value }
            
            //===
            
            mutate { $0.v = value }
        }
    }
    
    static
    func incFive() -> Action<GM>
    {
        return action { model, _, mutate in
            
            // this check is unnecessary here, just for demonstration:
            try UFL.verify("Current value was set") { model.v != nil }
            
            //===
            
            // this check ensures that current value is not nil,
            // as well as unwraps it for further use:
            let v = try UFL.extract("Get current value") { model.v }
            
            //===
            
            mutate { $0.v = v + 5 }
        }
    }
}
