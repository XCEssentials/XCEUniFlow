//
//  Action.swift
//  MKHUniFlow
//
//  Created by Maxim Khatskevich on 2/20/17.
//  Copyright © 2017 Maxim Khatskevich. All rights reserved.
//

import Foundation

//===

public
struct Action
{
    public
    let name: String
    
    // internal
    let body: ActionBody
    
    //===
    
    // internal
    init(_ name: String, _ body: @escaping ActionBody)
    {
        self.name = name
        self.body = body
    }
}
