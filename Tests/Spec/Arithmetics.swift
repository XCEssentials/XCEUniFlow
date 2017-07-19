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
        struct Main: FeatureState { typealias UFLFeature = Arithmetics
            
            var val: Int
        }
    }
}

//===

extension M.Arithmetics: ActionContext
{
    static
    func begin() -> Action
    {
        return action { model, mutate, next in
            
            try REQ.isNil("Feature is not initialized yet") {
                
                model ==> M.Arithmetics.self
            }
            
            //===
            
            mutate { $0 <== Main(val: 0) }
            
            //===
            
            next { setExplicit(value: 10) }
            next { incFive() }
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
            
            var a = try REQ.value("Feature is initialized") {
                
                model ==> Main.self
            }
            
            //===
            
            try REQ.isTrue("Current value is not equal to desired new value") {
                
                return a.val != value
            }
            
            //===
            
            a.val = value
            
            //===
            
            mutate { $0 <== a }
        }
    }
    
    static
    func incFive() -> Action
    {
        return action { model, mutate, _ in
            
            var a = try REQ.value("Feature is initialized") {
                
                model ==> Main.self
            }
            
            //===
            
            a.val += 5
            
            //===
            
            mutate { $0 <== a }
        }
    }
}
