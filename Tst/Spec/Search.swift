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

extension M
{
//    var search: Search
//    {
//        get
//        {
//            return self.extract(Search.feature, defaultValue: .undefined)
//        }
//        
//        set
//        {
//            self.merge(newValue)
//        }
//    }
}

//===

extension M
{
    enum Search: Feature
    {
        // it's a feature, but actual feature params
        // are split between different feature states,
        // which will be introduced as nested types
        
        //===
        
        struct Ready: FeatureState { typealias UFLFeature = Search
            
        }
        
        //===
        
        struct InProgress: FeatureState { typealias UFLFeature = Search
            
            var progress: Int
        }
        
        //===
        
        struct Complete: FeatureState { typealias UFLFeature = Search
            
            var value: Int
        }
        
        //===
        
        struct Failed: FeatureState { typealias UFLFeature = Search
            
            var error: Error
        }
    }
}

//===

extension M.Search
{
//    static
//    func initialize() -> Action
//    {
//        return action { m, mutate, next in
//            
//            try UFL.verify("Feature is not initialized yet") {
//                
//                switch m.search
//                {
//                    case .undefined:
//                        true
//                    
//                    default:
//                        false
//                }
//            }
//            
//            //===
//            
//            mutate { $0.search = .ready }
//            
//            //===
//            
//            next { begin() }
//        }
//    }
//    
//    //===
//    
//    static
//    func begin() -> Action
//    {
//        return action { m, mutate, next in
//            
//            try UFL.verify("Feature is ready") {
//                
//                m.search.map == .ready
//                
//                
////                if
////                    let s = M.Search.extracted(from: m),
////                    s == M.Search.ready
////                {
////                    print("YES")
////                }
//            }
//        }
//    }
}
