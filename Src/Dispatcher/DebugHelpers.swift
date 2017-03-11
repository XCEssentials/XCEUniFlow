//
//  DebugHelpers.swift
//  MKHUniFlow
//
//  Created by Maxim Khatskevich on 1/12/17.
//  Copyright © 2017 Maxim Khatskevich. All rights reserved.
//

import Foundation

//===

public
extension Dispatcher
{
    func enableDefaultReporting()
    {
        onReject = {
            
            print("===\\\\\\\\\\\\\\\\\\")
            
            print("MKHUniFlow: [-] \($0) REJECTED, error: \($1)")
            
            print("===/////////")
        }
    }
}
