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
        return data[GlobalModel.key(from: FS.ParentFeature.self)] as? FS
    }
    public
    func extract<FS: FeatureState>(defaultValue: FS) -> Any
    {
        return data[GlobalModel.key(from: FS.ParentFeature.self)] ?? defaultValue
    }
}

//=== MARK: SET

public
extension GlobalModel
{
    public
    mutating
    func merge<FS: FeatureState>(_ state: FS?)
    {
        data[GlobalModel.key(from: FS.ParentFeature.self)] = state
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
        data.removeValue(forKey: GlobalModel.key(from: F.self))
    }
}
