//
//  Extra.swift
//  MKHUniFlow
//
//  Created by Maxim Khatskevich on 12/22/16.
//  Copyright © 2016 Maxim Khatskevich. All rights reserved.
//

import Foundation

//===

public
enum Pre
{
    struct VerificationFailed: Error
    {
        let msg: String
        
        //===
        
        init(_ msg: String)
        {
            self.msg = "Verification [ " + msg + " ] failed."
        }
    }
    
    //===
    
    public
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
    
    public
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
