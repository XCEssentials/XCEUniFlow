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
    struct ActionRejected: Error
    {
        public
        let action: String
        
        public
        let reason: String
    }
    
    //===
    
    static
    func reject(_ reason: String? = nil, actionFullName: String = #function) -> ActionRejected
    {
        return
            ActionRejected(
                action: trimName(ofAction: actionFullName),
                reason: (reason ?? "State did not satisfy pre-conditions."))
    }
    
    //===
    
    static
    func trimName(ofAction actionFullName: String) -> String
    {
        return actionFullName.components(separatedBy: "(").first ?? ""
    }
}
