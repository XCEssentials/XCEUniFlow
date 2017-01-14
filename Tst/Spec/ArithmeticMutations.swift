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

enum ArithmeticMutations
{
    static
    func setExplicit(p: ActionParams<Int, GM>) -> Mutation<GM>
    {
        return { $0.v = p.input }
    }
    
    static
    func incFive(p: ActionShortParams<GM>) throws -> Mutation<GM>
    {
        // this check is unnecessary here, just for demonstration:
        try UFL.verify("Current value was set", self){ p.state.v != nil }
        
        //===
        
        // this check ensures that current value is not nil,
        // as well as unwraps it for further use:
        let v = try UFL.extract("Get current value", self){ p.state.v }
        
        //===
        
        return { $0.v = v + 5 }
    }
}
