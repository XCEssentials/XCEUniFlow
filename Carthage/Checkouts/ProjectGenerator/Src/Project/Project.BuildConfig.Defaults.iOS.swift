//
//  Project.BuildConfig.Defaults.iOS.swift
//  MKHProjGen
//
//  Created by Maxim Khatskevich on 3/16/17.
//  Copyright © 2017 Maxim Khatskevich. All rights reserved.
//

extension Project.BuildConfiguration.Defaults
{
    enum iOS
    {
        static
        func base(_ profiles: [String] = []) -> Project.BuildConfiguration.Base
        {
            return
                Project.BuildConfiguration
                    .Base(["platform:ios"] + profiles)
        }
        
        static
        func debug(_ profiles: [String] = []) -> Project.BuildConfiguration
        {
            return
                Project.BuildConfiguration
                    .Defaults
                    .debug(["ios:debug"] + profiles)
        }
        
        static
        func release(_ profiles: [String] = []) -> Project.BuildConfiguration
        {
            return
                Project.BuildConfiguration
                    .Defaults
                    .release(["ios:release"] + profiles)
        }
    }
}
