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

//public
//struct FeatureInitiationFailed: UFLError
//{
//    public
//    let feature: Any.Type
//    
//    //===
//    
//    // internal
//    init<F: Feature>(_ feature: F.Type)
//    {
//        self.feature = feature
//    }
//}
