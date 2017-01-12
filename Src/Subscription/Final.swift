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
class Subscription<State>
{
    // must be an object (class) to work with NSMapTable

    let onConvert: (_: State) -> Any?
    let onUpdate: (_: Any) -> Void

    //===

    init<SubState>(
        _ cvt: @escaping (_: State) -> SubState?,
        _ upd: @escaping (_: SubState) -> Void
        )
    {
        self.onConvert = cvt
        self.onUpdate = { upd($0 as! SubState) }
    }
}
