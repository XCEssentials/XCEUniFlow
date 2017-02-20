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
struct Action<UFLModel>
{
    let id: String
    
    let body: (UFLModel, @escaping (() -> Action<UFLModel>) -> Void, (Mutations<UFLModel>) -> Void) throws -> Void
}
