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
class Dispatcher
{
    //=== MARK: Private members
    
    var model = GlobalModel()
    
    var subscriptions =
        NSMapTable<AnyObject, Subscription>(
            keyOptions: .weakMemory,
            valueOptions: .strongMemory
        )
    
    //=== MARK: Public members
    
    public
    var onReject: ((_ actionId: String, _: Error) -> Void)?
    
    //=== Initializer
    
    public
    init() {}
}
