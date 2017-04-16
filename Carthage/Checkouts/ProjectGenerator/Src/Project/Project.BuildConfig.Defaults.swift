//
//  Project.BuildConfig.Defaults.swift
//  MKHProjGen
//
//  Created by Maxim Khatskevich on 3/16/17.
//  Copyright © 2017 Maxim Khatskevich. All rights reserved.
//

extension Project.BuildConfiguration
{
    enum Defaults
    {
        static
        func debug(_ profiles: [String] = []) -> Project.BuildConfiguration
        {
            return
                Project.BuildConfiguration(
                    "Debug",
                    .debug,
                    profiles
            )
        }
        
        static
        func release(_ profiles: [String] = []) -> Project.BuildConfiguration
        {
            return
                Project.BuildConfiguration(
                    "Release",
                    .release,
                    profiles
            )
        }
    }
}
