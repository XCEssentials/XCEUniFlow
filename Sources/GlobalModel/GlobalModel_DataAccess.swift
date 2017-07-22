//=== MARK: GET

public
extension Feature
{
    static
    func extract(from model: GlobalModel) -> Any?
    {
        return model.data[Self.key]
    }
}

//===

public
extension FeatureState
{
    static
    func extract(from model: GlobalModel) -> Self?
    {
        return model.data[Self.ParentFeature.key] as? Self
    }
}

//===

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
}

//=== MARK: SET

public
extension Optional where Wrapped: FeatureState
{
    func merge(into model: inout GlobalModel)
    {
        model.data[Wrapped.ParentFeature.key] = self
    }
}

public
extension FeatureState
{
    func merge(into model: inout GlobalModel)
    {
        model.data[Self.ParentFeature.key] = self
    }
}

//===

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
extension Feature
{
    static
    func remove(from model: inout GlobalModel)
    {
        model.data.removeValue(forKey: Self.key)
    }
}

//===

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
