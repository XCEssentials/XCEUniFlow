//
//  Pending.swift
//  MKHUniFlow
//
//  Created by Maxim Khatskevich on 1/12/17.
//  Copyright © 2017 Maxim Khatskevich. All rights reserved.
//

import Foundation

//===

public
struct SubscriptionPending<State: AppModel, SubState>
{
    let base: SubscriptionBlank<State>
    let onConvert: (_: State) -> SubState?
    
    //===
    
    public
    func onUpdate(
        _ upd: @escaping (_: SubState) -> Void
        )
    {
        base.dispatcher
            .register(
                base.observer,
                Subscription(onConvert, upd),
                base.initialUpdate)
    }
}
