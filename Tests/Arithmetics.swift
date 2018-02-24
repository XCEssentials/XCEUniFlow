//
//  Arithmetics.swift
//  MKHUniFlow
//
//  Created by Maxim Khatskevich on 1/15/17.
//  Copyright © 2017 Maxim Khatskevich. All rights reserved.
//

import Foundation

import XCEUniFlow
import XCERequirement

//===

enum Arithmetics: Feature, NoBindings
{
    struct Main: State { typealias Parent = Arithmetics
        
        var val: Int
    }
}

//===

extension Arithmetics
{
    static
    func begin() -> Action
    {
        return initialize.Into<Main>.via
        {
            become, submit in

            //---
            
            become << Main(val: 0)
            
            //---
            
            submit << [ setExplicit(value: 10),
                        incFive() ]
        }
    }
    
    static
    func setExplicit(value: Int) -> Action
    {
        return actualize.In<Main>.via
        {
            _, current, _ in

            //---

            try Require("Current value is != to desired new value").isTrue(
                
                current.val != value
            )
            
            //===
            
            current.val = value
        }
    }
    
    static
    func incFive() -> Action
    {
        return actualize.In<Main>.via
        {
            _, current, _ in

            //---
            
            current.val += 5
        }
    }
}
