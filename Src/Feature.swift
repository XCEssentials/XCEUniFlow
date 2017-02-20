//
//  Feature.swift
//  MKHUniFlow
//
//  Created by Maxim Khatskevich on 2/20/17.
//  Copyright © 2017 Maxim Khatskevich. All rights reserved.
//

import Foundation

//===

public
protocol Feature {}

//===

public
extension Feature
{
    static
        func action<UFLModel>(
        _ name: String = #function,
        _ body: @escaping (UFLModel, (Mutations<UFLModel>) -> Void, @escaping (() -> Action<UFLModel>) -> Void) throws -> Void
        ) -> Action<UFLModel>
    {
        return Action(id: "\(self).\(name)", body: body)
    }
}
