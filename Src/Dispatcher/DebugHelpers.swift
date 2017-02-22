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
            
            if
                let er = $1 as? ActionRejected
            {
                print("===\\\\\\\\\\\\\\\\\\")
                
                print(
                    "MKHUniFlow: [-] REJECTED \($0)",
                    "because \(er.reason)."
                )
                
                print("===/////////")
            }
            else
            {
                print("MKHUniFlow: [-] \($0) REJECTED, error: \($1)")
            }
        }
    }
}
