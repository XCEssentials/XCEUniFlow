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
        // it's a feature, but actual feature params
        // are split between different feature states,
        // which will be introduced as nested types
        
        //===
        
        struct Ready: SimpleState { typealias UFLFeature = Search
            
        }
        
        //===
        
        struct InProgress: FeatureState { typealias UFLFeature = Search
            
            var progress: Int
        }
        
        //===
        
        struct Complete: FeatureState { typealias UFLFeature = Search
            
            var results: [String]
        }
        
        //===
        
        struct Failed: SimpleState { typealias UFLFeature = Search
            
        }
    }
}

//===

extension M.Search
{
    static
    func initialize() -> Action
    {
        return initialization(into: Ready.self)
    }
    
    //===
    
    static
    func simulate() -> Action
    {
        return transition(from: Ready.self, into: InProgress.self) { _, become, next in
            
            become { InProgress(progress: 0) }
            
            //===
            
            next { update(progress: 10) }
            next { update(progress: 30) }
            next { update(progress: 70) }
            next { fail() }
            next { cleanup() }
        }
    }
    
    //===
    
    static
    func update(progress: Int) -> Action
    {
        return actualization(of: InProgress.self) { _, mutate, _ in
            
            _ = 1 // Xcode bug workaround
            
            mutate { $0.progress = progress }
        }
    }
    
    //===
    
    static
    func fail() -> Action
    {
        return transition(from: InProgress.self, into: Failed.self)
    }
    
    //===
    
    static
    func cleanup() -> Action
    {
        return deinitialization(from: Failed.self)
    }
}
