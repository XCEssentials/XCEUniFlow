//
//  Core.swift
//  MKHUniFlow
//
//  Created by Maxim Khatskevich on 1/12/17.
//  Copyright © 2017 Maxim Khatskevich. All rights reserved.
//

import Foundation

//===

public
final
class Dispatcher<State: AppModel>
{
    //=== MARK: Private members
    
    var state: State
    
    var subscriptions =
        NSMapTable<AnyObject, Subscription<State>>(
            keyOptions: .weakMemory,
            valueOptions: .strongMemory
    )
    
    //=== MARK: Public members
    
    public
    var onReject: ((_: ActionKind, _: Error) -> Void)?
    
    //=== Initializer
    
    public
    required
    init(_ initialState: State)
    {
        state = initialState
    }
}
