//
//  ActionContext.swift
//  MKHUniFlow
//
//  Created by Maxim Khatskevich on 2/22/17.
//  Copyright © 2017 Maxim Khatskevich. All rights reserved.
//

import Foundation

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
