//=== MARK: GET

public
extension Feature
{
    static
    func extract(from model: GlobalModel) -> Any?
    {
        return model.data[GlobalModel.key(for: Self.self)]
    }
}

//===

public
extension FeatureState
{
    static
    func extract(from model: GlobalModel) -> Self?
    {
        return model.data[GlobalModel.key(for: Self.ParentFeature.self)] as? Self
    }
}

//===

public
extension GlobalModel
{
    public
    func extract<F: Feature>(feature _: F.Type) -> Any?
    {
        return data[GlobalModel.key(for: F.self)]
    }
    
    public
    func extract<S: FeatureState>(state _: S.Type) -> S?
    {
        return data[GlobalModel.key(for: S.ParentFeature.self)] as? S
    }
}

//=== MARK: SET

public
extension Optional where Wrapped: FeatureState
{
    func merge(into model: inout GlobalModel)
    {
        model.data[GlobalModel.key(for: Wrapped.ParentFeature.self)] = self
    }
}

public
extension FeatureState
{
    func merge(into model: inout GlobalModel)
    {
        model.data[GlobalModel.key(for: Self.ParentFeature.self)] = self
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
        data[GlobalModel.key(for: S.ParentFeature.self)] = state
    }
}

//=== MARK: REMOVE

public
extension Feature
{
    static
    func remove(from model: inout GlobalModel)
    {
        model.data.removeValue(forKey: GlobalModel.key(for: Self.self))
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
        data.removeValue(forKey: GlobalModel.key(for: F.self))
    }
}
