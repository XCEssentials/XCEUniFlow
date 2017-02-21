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
    let id: String
    
    let body: (GlobalModel, (Mutations<GlobalModel>) -> Void, @escaping (() -> Action) -> Void) throws -> Void
    
    //===
    
    // internal
    init(
        _ id: String,
        _ body: @escaping (GlobalModel, (Mutations<GlobalModel>) -> Void, @escaping (() -> Action) -> Void) throws -> Void)
    {
        self.id = id
        self.body = body
    }
}
