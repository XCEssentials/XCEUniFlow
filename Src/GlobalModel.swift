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
typealias GM = GlobalModel

//===

public
typealias FeatureKey = String

//===

public
struct GlobalModel
{
    private
    var data: [FeatureKey: Any] = [:]
    
    //===
    
    static
    func key<F: Feature>(from _: F.Type) -> FeatureKey
    {
        return String(reflecting: F.self)
    }
    
    //===
    
    // internal
    init() {}
    
    //===
    
    public
    func extract<F: Feature>(feature _: F.Type) -> Any?
    {
        return data[GlobalModel.key(from: F.self)]
    }
    
    public
    func extract<FS: FeatureState>(state _: FS.Type) -> FS?
    {
        return data[GlobalModel.key(from: FS.UFLFeature.self)] as? FS
    }
    public
    func extract<FS: FeatureState>(defaultValue: FS) -> Any
    {
        return data[GlobalModel.key(from: FS.UFLFeature.self)] ?? defaultValue
    }
    
    public
    mutating
    func merge<FS: FeatureState>(_ state: FS?) -> Void
    {
        data[GlobalModel.key(from: FS.UFLFeature.self)] = state
    }
    
    public
    mutating
    func remove<F: Feature>(_: F.Type) -> Void
    {
        data.removeValue(forKey: GlobalModel.key(from: F.self))
    }
}

//===

infix operator <==

@discardableResult
public
func <== <FS: FeatureState>(global: inout GM, state: FS?) -> GM
{
    global.merge(state)
    
    //===
    
    return global
}

public
func <== <FS: FeatureState>(state: inout FS?, global: GM) -> Void
{
    state = global.extract(state: FS.self)
}

//===

infix operator ==>

@discardableResult
public
func ==> <F: Feature>(global: GM, _: F.Type) -> Any?
{
    return global.extract(feature: F.self)
}

@discardableResult
public
func ==> <FS: FeatureState>(global: GM, _: FS.Type) -> FS?
{
    return global.extract(state: FS.self)
}

//===

infix operator /==

@discardableResult
public
func /== <F: Feature>(global: inout GM, _: F.Type) -> GM
{
    global.remove(F.self)
    
    //===
    
    return global
}
