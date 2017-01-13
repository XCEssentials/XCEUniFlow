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
        _ context: Any = #file,
        _ action: String = #function,
        _ op: () -> Output?
        ) throws -> Output
    {
        guard
            let result = op()
        else
        {
            throw
                reject(
                    "verification [ \(description) ] failed",
                    context,
                    action
                )
        }
        
        //===
        
        return result
    }
    
    static
    func verify(
        _ description: String,
        _ context: Any = #file,
        _ action: String = #function,
        _ op: () -> Bool
        ) throws
    {
        if
            !op()
        {
            throw
                reject(
                    "verification [ \(description) ] failed",
                    context,
                    action
                )
        }
    }
}
