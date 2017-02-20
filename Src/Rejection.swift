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
extension UFL
{
    static
    func reject(_ reason: String? = nil) -> ActionRejected
    {
        return
            ActionRejected(
                reason ??
                "State did not satisfy pre-conditions")
    }
}
