//
//  PreVerification.swift
//  MKHUniFlow
//
//  Created by Maxim Khatskevich on 1/12/17.
//  Copyright © 2017 Maxim Khatskevich. All rights reserved.
//

import Foundation

//===

public
extension UFL
{
    static
    func extract<Output>(
        _ description: String,
        _ op: () -> Output?
        ) throws -> Output
    {
        guard
            let result = op()
        else
        {
            throw reject("verification [ \(description) ] failed")
        }
        
        //===
        
        return result
    }
    
    static
    func verify(
        _ description: String,
        _ op: () -> Bool
        ) throws
    {
        if
            !op()
        {
            throw reject("verification [ \(description) ] failed")
        }
    }
    
    static
    func isNil(
        _ description: String,
        _ op: () -> Any?
        ) throws
    {
        guard
            op() == nil
        else
        {
            throw reject("verification [ \(description) ] failed")
        }
    }
    
    static
    func isNotNil(
        _ description: String,
        _ op: () -> Any?
        ) throws
    {
        guard
            op() != nil
        else
        {
            throw reject("verification [ \(description) ] failed")
        }
    }
}
