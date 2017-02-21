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
typealias GMMutations = (_: inout GM) -> Void

public
typealias GMMutationsWrapped = (GMMutations) -> Void

public
typealias ActionGetter = () -> Action

public
typealias ActionGetterWrapped = (ActionGetter) -> Void

public
typealias ActionBody = (GM, GMMutationsWrapped, @escaping ActionGetterWrapped) throws -> Void

//===

public
struct Action
{
    let name: String
    let body: ActionBody
}

//===

public
protocol ActionContext {}

//===

public
extension ActionContext
{
    static
    func action(
        _ name: String = #function,
        _ body: @escaping ActionBody
        ) -> Action
    {
        return
            Action(
                name: "\(String(reflecting: self)).\(name)",
                body: body)
    }
}
