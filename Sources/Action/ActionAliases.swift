//
//  ActionAliases.swift
//  MKHUniFlow
//
//  Created by Maxim Khatskevich on 2/22/17.
//  Copyright © 2017 Maxim Khatskevich. All rights reserved.
//

import Foundation

//===

public
typealias GMMutations = (_: inout GlobalModel) -> Void

public
typealias GMMutationsWrapped = (GMMutations) -> Void

public
typealias ActionGetter = () -> Action

public
typealias ActionGetterWrapped = (ActionGetter) -> Void

public
typealias ActionBody = (GlobalModel, GMMutationsWrapped, @escaping ActionGetterWrapped) throws -> Void
