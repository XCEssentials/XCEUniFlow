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
    struct PreconditionFailed: Error
    {
        let msg: String
        
        //===
        
        init(_ msg: String)
        {
            self.msg = "Precondition [ " + msg + " ] failed."
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
            throw PreconditionFailed(title)
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
            throw PreconditionFailed(title)
        }
    }
}
