//
//  Blank.swift
//  MKHUniFlow
//
//  Created by Maxim Khatskevich on 1/12/17.
//  Copyright © 2017 Maxim Khatskevich. All rights reserved.
//

import Foundation

//===

public
struct SubscriptionBlank<State: AppModel>
{
    let observer: AnyObject
    let dispatcher: Dispatcher<State>
    let initialUpdate: Bool
    
    //===
    
    public
    func onConvert<SubState>(
        _ cvt: @escaping (_: State) -> SubState?
        )
        -> SubscriptionPending<State, SubState>
    {
        return SubscriptionPending(base: self, onConvert: cvt)
    }
    
    public
    func onUpdate(_ upd: @escaping (_: State) -> Void)
    {
        dispatcher
            .register(
                observer,
                Subscription({ $0 }, upd),
                initialUpdate)
    }
}
