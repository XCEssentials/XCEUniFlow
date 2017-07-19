//
//  GlobalModel.swift
//  MKHUniFlow
//
//  Created by Maxim Khatskevich on 2/20/17.
//  Copyright © 2017 Maxim Khatskevich. All rights reserved.
//

import Foundation

//===

public
typealias FeatureKey = String

//===

public
struct GlobalModel
{
    var data: [FeatureKey: Any] = [:]
    
    //===
    
    static
    func key<F: Feature>(from _: F.Type) -> FeatureKey
    {
        return String(reflecting: F.self)
    }
    
    //===
    
    init() {}
}
