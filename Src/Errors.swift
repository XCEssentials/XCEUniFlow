//
//  Errors.swift
//  MKHUniFlow
//
//  Created by Maxim Khatskevich on 2/20/17.
//  Copyright © 2017 Maxim Khatskevich. All rights reserved.
//

import Foundation

//===

public
protocol UFLError: Error {}

//===

public
struct ActionRejected: UFLError
{
    public
    let reason: String
    
    //===
    
    // internal
    init(_ reason: String)
    {
        self.reason = reason
    }
}

//===

public
struct FeatureReductionFailed: UFLError
{
    public
    let globalModel: Any.Type
    
    public
    let feature: Any.Type
    
    //===
    
    // internal
    init(globalModel: Any.Type, feature: Any.Type)
    {
        self.globalModel = globalModel
        self.feature = feature
    }
}
