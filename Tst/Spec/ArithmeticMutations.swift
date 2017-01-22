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
    func doTheChanges(_: GM, disp: Dispatcher<GM>)
    {
        disp.submit(setExplicit, with: 10)
        disp.submit(incFive)
    }
    
    static
    func setExplicit(value: Int, _: GM, _: Dispatcher<GM>) -> Mutations<GM>
    {
        return { $0.v = value }
    }
    
    static
    func incFive(state: GM, _: Dispatcher<GM>) throws -> Mutations<GM>
    {
        // this check is unnecessary here, just for demonstration:
        try UFL.verify("Current value was set", self){ state.v != nil }
        
        //===
        
        // this check ensures that current value is not nil,
        // as well as unwraps it for further use:
        let v = try UFL.extract("Get current value", self){ state.v }
        
        //===
        
        return { $0.v = v + 5 }
    }
}
