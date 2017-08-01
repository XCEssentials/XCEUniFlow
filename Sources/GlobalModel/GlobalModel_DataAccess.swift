//=== MARK: GET

public
extension GlobalModel
{
    public
    func extract<F: Feature>(feature _: F.Type) -> Any?
    {
        return data[GlobalModel.key(for: F.self)]
    }
    
    public
    func extract<F, S>(feature _: F.Type) -> S? where
        S: FeatureState,
        S.ParentFeature == F
    {
        return data[GlobalModel.key(for: F.self)] as? S
    }
    
    public
    func extract<S: FeatureState>(state _: S.Type) -> S?
    {
        return data[GlobalModel.key(for: S.ParentFeature.self)] as? S
    }
}

//=== MARK: SET

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

//=== MARK: REMOVE

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
