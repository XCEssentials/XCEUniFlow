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
    
    //===
    
    fileprivate
    init(
        _ reason: String
        )
    {
        self.reason = reason
    }
}

//===

public
extension UFL
{
    static
    func reject(_ reason: String? = nil) -> ActionRejected
    {
        return ActionRejected(reason ?? "State did not satisfy pre-conditions")
    }
}
