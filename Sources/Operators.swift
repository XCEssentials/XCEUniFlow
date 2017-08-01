//=== MARK: Summary

infix operator <== // gets value from GM and puts it into the left parameter, returns nothing

infix operator ==> // gets value from GM and returns it to outer scope

infix operator /== // removes value from GM, returns nothing

//=== MARK: GET

public
func <== <S: FeatureState>(state: inout S?, global: GlobalModel)
{
    state = global.extract(state: S.self)
}

@discardableResult
public
func ==> <F: Feature>(global: GlobalModel, _: F.Type) -> Any?
{
    return global.extract(feature: F.self)
}

@discardableResult
public
func ==> <F, S>(global: GlobalModel, _: F.Type) -> S? where
    S: FeatureState,
    S.ParentFeature == F
{
    return global.extract(feature: F.self)
}

@discardableResult
public
func ==> <S: FeatureState>(global: GlobalModel, _: S.Type) -> S?
{
    return global.extract(state: S.self)
}

//=== MARK: SET

public
func <== <S: FeatureState>(global: inout GlobalModel, state: S?)
{
    global.merge(state)
}

//=== MARK: REMOVE

public
func /== <F: Feature>(global: inout GlobalModel, _: F.Type)
{
    global.remove(F.self)
}
