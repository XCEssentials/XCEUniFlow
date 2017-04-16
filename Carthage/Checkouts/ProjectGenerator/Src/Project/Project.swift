//
//  Project.swift
//  MKHProjGen
//
//  Created by Maxim Khatskevich on 3/15/17.
//  Copyright © 2017 Maxim Khatskevich. All rights reserved.
//

public
struct Project
{
    public
    typealias BuildConfigurations =
    (
        all: BuildConfiguration.Base,
        debug: BuildConfiguration,
        release: BuildConfiguration
    )
    
    //---
    
    public
    let name: String
    
    //---
    
    public
    var configurations: BuildConfigurations =
    (
        BuildConfiguration.Base(
            // nothing on this level
        ),
        BuildConfiguration.Defaults.General.debug(
            //
        ),
        BuildConfiguration.Defaults.General.release(
            //
        )
    )
    
    public private(set)
    var targets: [Target] = []
    
    //---
    
    public
    init(
        _ name: String,
        _ configureProject: (inout Project) -> Void
        )
    {
        self.name = name
        
        //---
        
        configureProject(&self)
    }
    
    //===
    
    public
    mutating
    func target(
        _ name: String,
        _ platform: Platform,
        _ type: Target.InternalType,
        _ configureTarget: (inout Target) -> Void
        )
    {
        targets
            .append(Target(platform, name, type, configureTarget))
    }
}
