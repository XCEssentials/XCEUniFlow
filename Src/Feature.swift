//
//  Feature.swift
//  MKHUniFlow
//
//  Created by Maxim Khatskevich on 2/20/17.
//  Copyright © 2017 Maxim Khatskevich. All rights reserved.
//

import Foundation

//===

public
protocol Feature
{
    associatedtype UFLModel
    
    static
    func reduce(_ global: UFLModel) -> Self?
    
    static
    func merge(_ f: Self , to global: inout UFLModel) -> Void
}

//===

public
protocol FeatureState {}

//===

public
extension FeatureState
{
    static
    func action<F: Feature>(
        _ name: String = #function,
        _ body: @escaping (F, (Mutations<F>) -> Void, @escaping (() -> Action<F.UFLModel>) -> Void) throws -> Void
        ) -> Action<F.UFLModel>
    {
        return
            Action(id: "\(self).\(name)") { globalModel, mutateGlobal, next in
                
                guard
                    var f = F.reduce(globalModel)
                else
                {
                    throw
                        FeatureReductionFailed(
                            globalModel: F.UFLModel.self,
                            feature: F.self)
                }
                
                //===
                
                let mutateFeature: (Mutations<F>) -> Void = { $0(&f) }
                
                //===
                
                try body(f, mutateFeature, next)
                
                //===
                
                mutateGlobal { F.merge(f, to: &$0) }
            }
    }
}
