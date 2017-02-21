//
//  Arithmetics.swift
//  MKHUniFlow
//
//  Created by Maxim Khatskevich on 1/15/17.
//  Copyright © 2017 Maxim Khatskevich. All rights reserved.
//

import Foundation

import MKHUniFlow

//===

extension M
{
    struct Arithmetics: Feature
    {
        var v: Int
    }
}

//===

extension M.Arithmetics
{
    static
    func begin() -> Action
    {
        return action { m, mutate, next in
            
            try UFL.verify("Feature is not initialized yet") {
                
                M.Arithmetics.extracted(from: m) == nil
                // m.extract(M.Arithmetics.self) == nil
            }
            
            //===
            
            mutate { $0 <== M.Arithmetics(v: 0) }
            
            //===
            
            next { setExplicit(value: 10) }
            next { incFive() }
        }
    }
    
    static
    func setExplicit(value: Int) -> Action
    {
        return action { m, mutate, _ in
            
            // you have to check at least one precondition to
            // definitely avoid doing the same action twice:
            
            // also you need to put at least something before
            // writing mutation code
            // to be able to use short closure notation
            // (without explicit input parameters type declaration) and
            // not getting the "parameter may not have 'var' specifier"
            // LOL Xcode bug, I guess...
            
            var a = try UFL.extract("The feature was started") {
                
                M.Arithmetics.extracted(from: m)
            }
            
            //===
            
            try UFL.verify("Current value is not equal to desired new value") {
                
                return a.v != value
            }
            
            //===
            
            a.v = value
            
            //===
            
            mutate { $0 <== a }
        }
    }
    
    static
    func incFive() -> Action
    {
        return action { m, mutate, _ in
            
            var a = try UFL.extract("The feature was started") {
                
                M.Arithmetics.extracted(from: m)
            }
            
            //===
            
            a.v += 5
            
            //===
            
            mutate { $0 <== a }
        }
    }
}
