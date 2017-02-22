//
//  GlobalModel.Operators.swift
//  MKHUniFlow
//
//  Created by Maxim Khatskevich on 2/22/17.
//  Copyright © 2017 Maxim Khatskevich. All rights reserved.
//

import Foundation

//=== MARK: Summary

infix operator <== // gets value from GM and puts it into the left parameter, returns nothing

infix operator ==> // gets value from GM and returns it to outer scope

infix operator /== // removes value from GM, returns nothing

//=== MARK: GET

public
func <== <FS: FeatureState>(state: inout FS?, global: GlobalModel) -> Void
{
    state = global.extract(state: FS.self)
}

@discardableResult
public
func ==> <F: Feature>(global: GlobalModel, _: F.Type) -> Any?
{
    return global.extract(feature: F.self)
}

@discardableResult
public
func ==> <FS: FeatureState>(global: GlobalModel, _: FS.Type) -> FS?
{
    return global.extract(state: FS.self)
}

//=== MARK: SET

public
func <== <FS: FeatureState>(global: inout GlobalModel, state: FS?)
{
    global.merge(state)
}

//=== MARK: REMOVE

public
func /== <F: Feature>(global: inout GlobalModel, _: F.Type)
{
    global.remove(F.self)
}
