//
//  Target.Script.swift
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
    struct Scripts
    {
        public private(set)
        var regulars: [String] = []
        
        public
        mutating
        func regular(_ paths: String...)
        {
            regulars.append(contentsOf: paths)
        }
        
        //---
        
        public private(set)
        var beforeBuilds: [String] = []
        
        public
        mutating
        func beforeBuild(_ paths: String...)
        {
            beforeBuilds.append(contentsOf: paths)
        }
        
        //---
        
        public private(set)
        var afterBuilds: [String] = []
        
        public
        mutating
        func afterBuild(_ paths: String...)
        {
            afterBuilds.append(contentsOf: paths)
        }
    }
}
