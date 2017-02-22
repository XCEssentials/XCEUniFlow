//
//  GlobalModel.DataAccess.swift
//  MKHUniFlow
//
//  Created by Maxim Khatskevich on 2/22/17.
//  Copyright © 2017 Maxim Khatskevich. All rights reserved.
//

import Foundation

//=== MARK: GET

public
extension GlobalModel
{
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
}

//=== MARK: SET

public
extension GlobalModel
{
    public
    mutating
    func merge<FS: FeatureState>(_ state: FS?) -> Void
    {
        data[GlobalModel.key(from: FS.UFLFeature.self)] = state
    }
}

//=== MARK: REMOVE

public
extension GlobalModel
{
    public
    mutating
    func remove<F: Feature>(_: F.Type) -> Void
    {
        data.removeValue(forKey: GlobalModel.key(from: F.self))
    }
}
