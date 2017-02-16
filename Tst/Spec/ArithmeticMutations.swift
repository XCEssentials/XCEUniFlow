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
        return action { _, _, mutate in
            
            print("")
            
            
            mutate { // (m: inout GM) in
                
                $0.v = value
            }
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
