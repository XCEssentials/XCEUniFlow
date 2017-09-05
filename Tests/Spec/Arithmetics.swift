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

extension M
{
    enum Arithmetics: Feature
    {
        struct Main: FeatureState { typealias ParentFeature = Arithmetics
            
            var val: Int
        }
    }
}

//===

enum Actions: ActionContext
{
    static
    func begin() -> Action
    {
        return action { model, mutate, submit in
            
            try Require("Feature is not initialized yet").isNil(
                
                model >> M.Arithmetics.self
            )
            
            //===
            
            mutate { $0 << M.Arithmetics.Main(val: 0) }
            
            //===
            
            submit << setExplicit(value: 10)
            submit << incFive
        }
    }
    
    static
    func setExplicit(value: Int) -> Action
    {
        return action { model, mutate, _ in
            
            // you have to check at least one precondition to
            // definitely avoid doing the same action twice:
            
            // also you need to put at least something before
            // writing mutation code
            // to be able to use short closure notation
            // (without explicit input parameters type declaration) and
            // not getting the "parameter may not have 'var' specifier"
            // LOL Xcode bug, I guess...
            
            var a = try Require("Feature is initialized").isNotNil(
                
                model >> M.Arithmetics.Main.self
            )
            
            //===
            
            try Require("Current value is != to desired new value").isTrue(
                
                a.val != value
            )
            
            //===
            
            a.val = value
            
            //===
            
            mutate { $0 << a }
        }
    }
    
    static
    func incFive() -> Action
    {
        return action { model, mutate, _ in
            
            var a = try Require("Feature is initialized").isNotNil(
                
                model >> M.Arithmetics.Main.self
            )
            
            //===
            
            a.val += 5
            
            //===
            
            mutate { $0 << a }
        }
    }
}
