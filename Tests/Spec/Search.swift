//
//  Search.swift
//  MKHUniFlow
//
//  Created by Maxim Khatskevich on 2/20/17.
//  Copyright © 2017 Maxim Khatskevich. All rights reserved.
//

import Foundation

import XCEUniFlow

//===

extension M
{
    enum Search: Feature
    {
        // it's a feature, but actual feature params
        // are split between different feature states,
        // which will be introduced as nested types
        
        //===
        
        struct Ready: SimpleState { typealias ParentFeature = Search
            
        }
        
        //===
        
        struct InProgress: FeatureState { typealias ParentFeature = Search
            
            var progress: Int
        }
        
        //===
        
        struct Complete: FeatureState { typealias ParentFeature = Search
            
            var results: [String]
        }
        
        //===
        
        struct Failed: SimpleState { typealias ParentFeature = Search
            
        }
    }
}

//===

extension M.Search
{
    static
    func initialize() -> Action
    {
        return initialization.Into<Ready>.automatic()
    }
    
    //===
    
    static
    func begin() -> Action
    {
        return trigger.In<Ready>.via { _, submit in
            
            submit << simulate
        }
    }
    
    //===
    
    static
    func simulate() -> Action
    {
        return transition.Between<Ready, InProgress>.via { _, become, submit in
            
            become << InProgress(progress: 0)
            
            //===
            
            submit << update(progress: 10)
            submit << update(progress: 30)
            submit << update(progress: 70)
            submit << fail
            submit << cleanup
        }
    }
    
    //===
    
    static
    func update(progress: Int) -> Action
    {
        return actualization.In<InProgress>.via { _, mutate, _ in
            
            _ = 0 // Xcode bug workaround
            
            mutate { $0.progress = progress }
        }
    }
    
    //===
    
    static
    func fail() -> Action
    {
        return transition.Between<InProgress, Failed>.automatic()
    }
    
    //===
    
    static
    func cleanup() -> Action
    {
        return deinitialization.From<Failed>.automatic()
    }
}
