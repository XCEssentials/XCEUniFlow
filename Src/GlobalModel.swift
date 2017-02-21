//
//  GlobalModel.swift
//  MKHUniFlow
//
//  Created by Maxim Khatskevich on 2/20/17.
//  Copyright © 2017 Maxim Khatskevich. All rights reserved.
//

import Foundation

//===

public
struct GlobalModel
{
    private
    var data: [String: Feature] = [:]
    
    //===
    
    private
    static
    func key<F: Feature>(from feature: F.Type) -> String
    {
        return String(reflecting: feature.self)
    }
    
    //===
    
    // internal
    init() {}
    
    //===
    
    public
    func extract<F: Feature>(_: F.Type) -> F?
    {
        return data[GlobalModel.key(from: F.self)] as? F
    }
    
    public
    mutating
    func merge<F: Feature>(_ feature: F?) -> Void
    {
        data[GlobalModel.key(from: F.self)] = feature
    }
    
    public
    mutating
    func remove<F: Feature>(_ featureOfType: F.Type) -> Void
    {
        data.removeValue(forKey: GlobalModel.key(from: F.self))
    }
}

//===

infix operator <==

@discardableResult
public
func <== <F: Feature>(global: inout GlobalModel, feature: F) -> GlobalModel
{
    global.merge(feature)
    
    //===
    
    return global
}
