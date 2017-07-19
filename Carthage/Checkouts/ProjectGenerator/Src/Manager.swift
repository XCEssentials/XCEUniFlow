//
//  Manager.swift
//  MKHProjGen
//
//  Created by Maxim Khatskevich on 3/16/17.
//  Copyright © 2017 Maxim Khatskevich. All rights reserved.
//

public
enum Manager
{
    public
    static
    func prepareSpec(
        _ format: Spec.Format,
        for project: Project
        ) -> String
    {
        let rawSpec: RawSpec
        
        //===
        
        switch format
        {
            case .v1_2_1:
                rawSpec = Spec_1_2_1.generate(for: project)
            
            case .v1_3_0:
                rawSpec = Spec_1_3_0.generate(for: project)
            
            case .v2_0_0:
                rawSpec = Spec_2_0_0.generate(for: project)
            
            case .v2_1_0:
                rawSpec = Spec_2_1_0.generate(for: project)
        }
        
        //===
        
        return rawSpec
            .map { "\(Spec.ident($0))\($1)" }
            .joined(separator: "\n")
    }
}
