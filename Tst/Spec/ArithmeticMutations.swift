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
        return action {
            
            $0.submit { ArithmeticMutations.setExplicit(value: 10) }
            $0.submit { ArithmeticMutations.incFive() }
        }
    }
    
    static
    func setExplicit(value: Int) -> Action<GM>
    {
        return action {
            
            $0.mutate { $0.v = value }
        }
    }
    
    static
    func incFive() -> Action<GM>
    {
        return action { p in
            
            // this check is unnecessary here, just for demonstration:
            try UFL.verify("Current value was set") { p.model.v != nil }
            
            //===
            
            // this check ensures that current value is not nil,
            // as well as unwraps it for further use:
            let v = try UFL.extract("Get current value") { p.model.v }
            
            //===
            
            p.mutate { $0.v = v + 5 }
        }
    }
}
