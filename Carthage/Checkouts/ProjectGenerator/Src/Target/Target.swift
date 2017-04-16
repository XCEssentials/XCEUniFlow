//
//  Target.swift
//  MKHProjGen
//
//  Created by Maxim Khatskevich on 3/16/17.
//  Copyright © 2017 Maxim Khatskevich. All rights reserved.
//

public
extension Project
{
    public
    struct Target
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
        
        public
        let platform: Platform
        
        public
        let type: InternalType
        
        //---
        
        public private(set)
        var includes: [String] = []
        
        public
        mutating
        func include(_ paths: String...)
        {
            includes.append(contentsOf: paths)
        }
        
        //---
        
        public private(set)
        var excludes: [String] = []
        
        public
        mutating
        func exclude(_ patterns: String...)
        {
            excludes.append(contentsOf: patterns)
        }
        
        //---
        
        public
        var sourceOptions: [String: String] = [:]
        
        //---
        
        public private(set)
        var i18nResources: [String] = []
        
        public
        mutating
        func i18nResource(_ paths: String...)
        {
            i18nResources.append(contentsOf: paths)
        }
        
        //---
        
        public
        var configurations: BuildConfigurations =
        (
            Project.Target.BuildConfiguration.Base(
                //
            ),
            Project.Target.BuildConfiguration(
                Project.BuildConfiguration.Defaults.iOS.debug().name
            ),
            Project.Target.BuildConfiguration(
                Project.BuildConfiguration.Defaults.iOS.release().name
            )
        )
        
        public
        var dependencies = Dependencies()
        
        public
        var scripts = Scripts()
        
        public
        var includeCocoapods = false
        
        //---
        
        public private(set)
        var tests: [Target] = []
        
        public
        mutating
        func unitTests(
            _ name: String = "Tests",
            _ configureTarget: (inout Target) -> Void
            )
        {
            var ut = Target(self.platform, name, .unitTest, configureTarget)
            
            //===
            
            ut.dependencies.otherTarget(self.name)
            
            if
                type == .app
            {
                ut.configurations.all.override(
                    
                    // https://github.com/workshop/struct/blob/master/examples/iOS_Application/project.yml#L115
                    "TEST_HOST"
                        <<< "$(BUILT_PRODUCTS_DIR)/\(self.name).app/\(self.name)"
                )
            }
            
            //===
            
            tests.append(ut)
        }
        
        public
        mutating
        func uiTests(
            _ name: String = "UITests",
            _ configureTarget: (inout Target) -> Void
            )
        {
            var uit = Target(self.platform, name, .uiTest, configureTarget)
            
            uit.dependencies.otherTarget(self.name)
            
            //===
            
            tests.append(uit)
        }
        
        //---
        
        // internal
        init(
            _ platform: Platform,
            _ name: String,
            _ type: InternalType,
            _ configureTarget: (inout Target) -> Void
            )
        {
            self.name = name
            self.platform = platform
            self.type = type
            
            //---
            
            configureTarget(&self)
        }
    }
}
