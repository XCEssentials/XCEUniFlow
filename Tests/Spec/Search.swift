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

enum Search: Feature
{
    // it's a feature, but actual feature params
    // are split between different feature states,
    // which will be introduced as nested types
    
    //===
    
    struct Ready: FeatureStateAuto { typealias ParentFeature = Search
        
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
    
    struct Failed: FeatureStateAuto { typealias ParentFeature = Search
        
    }
}

//===

extension Search
{
    static
    func setup() -> Action
    {
        return initialize.Into<Ready>.automatically()
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
            
            submit << [ update(progress: 10),
                        update(progress: 30),
                        update(progress: 70) ]
            
            submit << [ fail,
                        cleanup ]
        }
    }
    
    //===
    
    static
    func update(progress: Int) -> Action
    {
        return actualize.In<InProgress>.via { current, _ in
            
            current.progress = progress
        }
    }
    
    //===
    
    static
    func fail() -> Action
    {
        return transition.Between<InProgress, Failed>.automatically()
    }
    
    //===
    
    static
    func cleanup() -> Action
    {
        return deinitialize.From<Failed>.automatically()
    }
}
