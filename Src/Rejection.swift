//
//  Rejection.swift
//  MKHUniFlow
//
//  Created by Maxim Khatskevich on 1/12/17.
//  Copyright © 2017 Maxim Khatskevich. All rights reserved.
//

import Foundation

//===

public
struct ActionRejected: Error
{
    public
    let reason: String
    
    public
    let context: String
    
    public
    let action: String
    
    //===
    
    fileprivate
    init(
        _ reason: String,
        _ context: String,
        _ action: String
        )
    {
        self.reason = reason
        self.context = context
        self.action = action
    }
}

//===

public
extension UFL
{
    static
    func reject(
        _ reason: String? = nil,
        _ context: Any = #file,
        _ action: String = #function) -> ActionRejected
    {
        return
            ActionRejected(
                (reason ?? "State did not satisfy pre-conditions"),
                (context as? String) ?? String(reflecting: context),
                trimName(of: action))
    }
    
    //===
    
    static
    func trimName(of actionFullName: String) -> String
    {
        return actionFullName.components(separatedBy: "(").first ?? ""
    }
}
