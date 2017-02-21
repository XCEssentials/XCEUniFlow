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
    enum Search: Feature
    {
        // it's a feature, but actual feature implementation
        // is split between different feature states,
        // which will be introduced as nested types
        
        //===
        
        case ready
        
        //===
        
        case inProgress
        
        //===
        
        case complete
        
        //===
        
        case failed
    }
}

//===

extension M.Search
{
//    static
//    func begin() -> Action
//    {
//        return action { m, mutate, next in
//            
//            try UFL.verify("Feature is not initialized yet") {
//                
//                M.Search.reduce(from: m) == nil
//            }
//            
//            //===
//            
//            mutate { $0.merge(M.Search.ready) }
//            
//            //===
//            
////            next { setExplicit(value: 10) }
////            next { incFive() }
//        }
//    }
}
