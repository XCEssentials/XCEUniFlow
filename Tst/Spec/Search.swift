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
    struct SearchFailed: Error {}
}

//===

extension M.Search
{
    static
    func initialize() -> Action
    {
        return initiation(to: Ready.self) { become, _ in
            
            become { Ready() }
        }
    }
    
    //===
    
    static
    func simulate() -> Action
    {
        return transition(from: Ready.self, to: InProgress.self) { r, become, next in
            
            become { InProgress(progress: 0) }
            
            //===
            
            next { update(progress: 10) }
            next { update(progress: 30) }
            next { update(progress: 70) }
            next { fail(error: SearchFailed()) }
        }
    }
    
    //===
    
    static
    func update(progress: Int) -> Action
    {
        return actualization(current: InProgress.self) { p, mutate, _ in
            
            _ = p // Xcode bug workaround
            
            mutate { $0.progress = progress }
        }
    }
    
    //===
    
    static
    func fail(error: Error) -> Action
    {
        return transition(from: InProgress.self, to: Failed.self) { p, become, next in
            
            _ = p // Xcode bug workaround
            
            become { Failed(error: error) }
            
            //===
            
            next { cleanup() }
        }
    }
    
    //===
    
    static
    func cleanup() -> Action
    {
        return deinitiation(from: Failed.self) { _, _, _ in }
    }
}
