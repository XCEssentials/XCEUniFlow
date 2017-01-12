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
    struct VerificationFailed: Error
    {
        let msg: String
        
        //===
        
        init(_ title: String)
        {
            self.msg = "Verification [ \(title) ] failed."
        }
    }
    
    //===
    
    static
    func extract<Output>(_ title: String, _ op: () -> Output?) throws -> Output
    {
        guard
            let result = op()
        else
        {
            throw VerificationFailed(title)
        }
        
        //===
        
        return result
    }
    
    static
    func verify(_ title: String, _ op: () -> Bool) throws
    {
        if
            !op()
        {
            throw VerificationFailed(title)
        }
    }
}
