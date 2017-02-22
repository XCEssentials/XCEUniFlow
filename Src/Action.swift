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

//===

public
protocol ActionContext {}

//===

public
extension ActionContext
{
    static
    var name: String { return String(reflecting: Self.self) }
    
    static
    func action(_ name: String = #function, body: @escaping ActionBody) -> Action
    {
        return Action("\(self.name).\(name)", body)
    }
}
