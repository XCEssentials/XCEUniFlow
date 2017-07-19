//
//  Final.swift
//  MKHUniFlowb
//
//  Created by Maxim Khatskevich on 1/12/17.
//  Copyright © 2017 Maxim Khatskevich. All rights reserved.
//

import Foundation

//===

final
class Subscription
{
    // must be an object (class) to work with NSMapTable

    let onConvert: (_: GlobalModel) -> Any?
    let onUpdate: (_: Any) -> Void

    //===

    init<UFLSubState>(
        _ cvt: @escaping (_: GlobalModel) -> UFLSubState?,
        _ upd: @escaping (_: UFLSubState) -> Void
        )
    {
        self.onConvert = cvt
        self.onUpdate = { upd($0 as! UFLSubState) }
    }
}
