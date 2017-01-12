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
typealias ActionParams<Input, State: AppModel> = (
    input: Input,
    state: State,
    dispatcher: Dispatcher<State>
)

public
typealias ActionShortParams<State: AppModel> = (
    state: State,
    dispatcher: Dispatcher<State>
)

//===

public
typealias Mutation<State> = (_ state: inout State) -> Void
