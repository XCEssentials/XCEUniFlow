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
struct SubscriptionBlank
{
    let observer: AnyObject
    let dispatcher: Dispatcher
    let initialUpdate: Bool
    
    //===
    
    public
    func onConvert<UFLSubState>(
        _ cvt: @escaping (_: GlobalModel) -> UFLSubState?
        )
        -> SubscriptionPending<UFLSubState>
    {
        return SubscriptionPending(base: self, onConvert: cvt)
    }
    
    public
    func onUpdate(_ upd: @escaping (_: GlobalModel) -> Void)
    {
        dispatcher
            .register(
                observer,
                Subscription({ $0 }, upd),
                initialUpdate)
    }
}
