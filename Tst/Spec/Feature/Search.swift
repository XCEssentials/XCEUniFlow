//
//  Search.swift
//  MKHUniFlow
//
//  Created by Maxim Khatskevich on 2/20/17.
//  Copyright © 2017 Maxim Khatskevich. All rights reserved.
//

import Foundation

import MKHUniFlow

//===

protocol M_Search: Feature {}

//===

//protocol M_SearchState: FeatureState {}

//===

extension M_Search
{
    static
    func reduce(_ global: GM) -> Self?
    {
        return global.search
    }
    
    static
    func merge(_ f: M_Search , to global: inout GM) -> Void
    {
        global.search = f
    }
}

//===

extension M
{
    enum Search
    {
        // again, just for namespace,
        // it's a feature, but actual feature implementation
        // is split between different feature states,
        // which will be introduced as nested types
        
        //===
        
        struct Ready // : M_SearchState
        {
            //
        }
    }
}
