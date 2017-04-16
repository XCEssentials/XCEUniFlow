//
//  Project.BuildConfig.Defaults.General.swift
//  MKHProjGen
//
//  Created by Maxim Khatskevich on 3/16/17.
//  Copyright © 2017 Maxim Khatskevich. All rights reserved.
//

extension Project.BuildConfiguration.Defaults
{
    enum General
    {
        static
        func debug(_ profiles: [String] = []) -> Project.BuildConfiguration
        {
            return
                Project.BuildConfiguration
                    .Defaults
                    .debug(["general:debug"] + profiles)
        }
        
        static
        func release(_ profiles: [String] = []) -> Project.BuildConfiguration
        {
            return
                Project.BuildConfiguration
                    .Defaults
                    .release(["general:release"] + profiles)
        }
    }
}
