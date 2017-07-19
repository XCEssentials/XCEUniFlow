//
//  FeatureState.swift
//  MKHUniFlow
//
//  Created by Maxim Khatskevich on 2/22/17.
//  Copyright © 2017 Maxim Khatskevich. All rights reserved.
//

import Foundation

//===

public
protocol FeatureState
{
    associatedtype UFLFeature: Feature
}

//===

public
protocol SimpleState: FeatureState
{
    init()
}
