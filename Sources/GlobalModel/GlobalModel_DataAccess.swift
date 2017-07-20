//=== MARK: GET

public
extension GlobalModel
{
    public
    func extract<F: Feature>(feature _: F.Type) -> Any?
    {
        return data[F.key]
    }
    
    public
    func extract<S: FeatureState>(state _: S.Type) -> S?
    {
        return data[S.ParentFeature.key] as? S
    }
    public
    func extract<S: FeatureState>(defaultValue: S) -> Any
    {
        return data[S.ParentFeature.key] ?? defaultValue
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
        data[S.ParentFeature.key] = state
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
        data.removeValue(forKey: F.key)
    }
}
