public
struct GlobalModel
{
    var data: [Key: Any] = [:]
    
    //===
    
    init() {}
}

// MARK: Key

extension GlobalModel
{
    typealias Key = String
    
    static
        func key(for feature: Feature.Type) -> Key
    {
        return Key(reflecting: self)
    }
}

// MARK: Methods - GET

public
extension GlobalModel
{
    public
    func extract<F: Feature>(feature _: F.Type) -> Any?
    {
        return data[GlobalModel.key(for: F.self)]
    }
    
    //===
    
    public
    func extract<F, S>(feature _: F.Type) -> S? where
        S: FeatureState,
        S.ParentFeature == F
    {
        return data[GlobalModel.key(for: F.self)] as? S
    }
    
    //===
    
    public
    func extract<S: FeatureState>(state _: S.Type) -> S?
    {
        return data[GlobalModel.key(for: S.ParentFeature.self)] as? S
    }
}

//===

public
extension Feature
{
    static
    func from(_ globalModel: GlobalModel) -> Any?
    {
        return globalModel.extract(feature: self)
    }
    
    //===
    
    static
    func from<S>(_ globalModel: GlobalModel) -> S? where
        S: FeatureState,
        S.ParentFeature == Self
    {
        return globalModel.extract(feature: self)
    }
    
    //===
    
    static
    func presented(in globalModel: GlobalModel) -> Bool
    {
        return from(globalModel) != nil
    }
}

//===

public
extension FeatureState
{
    static
    func from(_ globalModel: GlobalModel) -> Self?
    {
        return globalModel.extract(state: self)
    }
    
    //===
    
    static
    func presented(in globalModel: GlobalModel) -> Bool
    {
        return from(globalModel) != nil
    }
}

// MARK: Methods - SET

public
extension GlobalModel
{
    public
    mutating
    func merge<S: FeatureState>(_ state: S?)
    {
        data[GlobalModel.key(for: S.ParentFeature.self)] = state
    }
}

// MARK: Methods - REMOVE

public
extension GlobalModel
{
    public
    mutating
    func remove<F: Feature>(_: F.Type)
    {
        data.removeValue(forKey: GlobalModel.key(for: F.self))
    }
}

// MARK: Operators - Summary

infix operator <== // gets value from GM

infix operator ==> // gets value from GM and returns it to outer scope

infix operator /== // removes value from GM, returns nothing

// MARK: Operators - GET

public
func <== <S: FeatureState>(_: S.Type, global: GlobalModel) -> S?
{
    return global.extract(state: S.self)
}

//===

public
func <== <F: Feature>(_: F.Type, global: GlobalModel) -> Any?
{
    return global.extract(feature: F.self)
}

//===

public
func ==> <F: Feature>(global: GlobalModel, _: F.Type) -> Any?
{
    return global.extract(feature: F.self)
}

//===

public
func ==> <F, S>(global: GlobalModel, _: F.Type) -> S? where
    S: FeatureState,
    S.ParentFeature == F
{
    return global.extract(feature: F.self)
}

//===

public
func ==> <S: FeatureState>(global: GlobalModel, _: S.Type) -> S?
{
    return global.extract(state: S.self)
}

// MARK: Operators - SET

public
func <== <S: FeatureState>(global: inout GlobalModel, state: S?)
{
    global.merge(state)
}

// MARK: Operators - REMOVE

public
func /== <F: Feature>(global: inout GlobalModel, _: F.Type)
{
    global.remove(F.self)
}
