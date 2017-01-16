//
//  TypeAliases.swift
//  MKHUniFlow
//
//  Created by Maxim Khatskevich on 1/12/17.
//  Copyright © 2017 Maxim Khatskevich. All rights reserved.
//

import Foundation

//===

public
typealias Mutations<State> = (_: inout State) -> Void

public
typealias Triggers<State: AppModel> = (_: Dispatcher<State>) -> Void
