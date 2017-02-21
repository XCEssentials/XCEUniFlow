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

extension M.Search: ActionContext
{
    static
    func initialize() -> Action
    {
        return action { m, mutate, _ in
            
            try UFL.isNil("Search is not initialized yet") {
                
                m ==> M.Search.self
            }
            
            //===
            
            mutate { $0 <== Ready() }
        }
    }
    
    //===
    
    static
    func simulate() -> Action
    {
        return action { m, mutate, next in
            
            try UFL.isNotNil("Search is ready") {
                
                m ==> Ready.self
            }
            
            //===
            
            mutate { $0 <== InProgress(progress: 0) }
            
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
        return action { m, mutate, _ in
            
            var p = try UFL.extract("Search is in progress") {
                
                m ==> InProgress.self
            }
            
            //===
            
            p.progress = progress
            
            //===
            
            mutate { $0 <== p }
        }
    }
    
    //===
    
    static
    func fail(error: Error) -> Action
    {
        return action { m, mutate, _ in
            
            try UFL.isNotNil("Search is in progress") {
                
                m ==> InProgress.self
            }
            
            //===
            
            mutate { $0 <== Failed(error: error) }
        }
    }
}
