//
//  Project.BuildConfig.swift
//  MKHProjGen
//
//  Created by Maxim Khatskevich on 3/18/17.
//  Copyright © 2017 Maxim Khatskevich. All rights reserved.
//

import Foundation

//===

public
extension Project.Target
{
    public
    struct BuildConfiguration
    {
        public
        struct Base
        {
            // internal
            init(_ overrides: [KeyValuePair] = [])
            {
                self.overrides = overrides
            }
            
            //===
            
            public private(set)
            var overrides: [KeyValuePair] = []
            
            public
            mutating
            func override(_ pairs: KeyValuePair...)
            {
                overrides.append(contentsOf: pairs)
            }
        }
        
        //===
        
        public
        let name: String
        
        //---
        
        public private(set)
        var overrides: [KeyValuePair] = []
        
        public
        mutating
        func override(_ pairs: KeyValuePair...)
        {
            overrides.append(contentsOf: pairs)
        }
        
        //---
        
        // internal
        init(
            _ name: String
            )
        {
            self.name = name
        }
    }
}
