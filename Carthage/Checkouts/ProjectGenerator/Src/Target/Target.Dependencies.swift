//
//  Target.Dependencies.swift
//  MKHProjGen
//
//  Created by Maxim Khatskevich on 3/17/17.
//  Copyright © 2017 Maxim Khatskevich. All rights reserved.
//

import Foundation

//===

public
extension Project.Target
{
    public
    typealias BinaryDependency =
        (
        location: String,
        codeSignOnCopy: Bool
    )
    
    public
    typealias ProjectDependencies =
        (
        location: String,
        frameworks: [ProjectDependency]
    )
    
    public
    typealias ProjectDependency =
        (
        name: String,
        copy: Bool,
        codeSignOnCopy: Bool
    )
    
    //===
    
    public
    struct Dependencies
    {
        public private(set)
        var fromSDKs: [String] = []
        
        public
        mutating
        func fromSDK(_ element: String...)
        {
            fromSDKs.append(contentsOf: element)
        }
        
        //===
        
        public private(set)
        var otherTargets: [String] = []
        
        public
        mutating
        func otherTarget(_ element: String...)
        {
            otherTargets.append(contentsOf: element)
        }
        
        //===
        
        public private(set)
        var binaries: [BinaryDependency] = []
        
        public
        mutating
        func binary(_ element: BinaryDependency...)
        {
            binaries.append(contentsOf: element)
        }
        
        //===
        
        public private(set)
        var projects: [ProjectDependencies] = []
        
        public
        mutating
        func project(_ element: ProjectDependencies...)
        {
            projects.append(contentsOf: element)
        }
        
        //===
        
        // internal
        init()
        {
            //
        }
    }
}
