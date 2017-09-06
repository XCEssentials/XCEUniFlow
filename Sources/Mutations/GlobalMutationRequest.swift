public
protocol GlobalMutationRequest
{
    var feature: Feature.Type { get }
}

//===

public
struct Store<S: FeatureState>: GlobalMutationRequest
{
    public
    var feature: Feature.Type
    {
        return S.ParentFeature.self
    }
    
    public
    let state: S
    
    public
    init(state: S)
    {
        self.state = state
    }
}

//===

public
struct Remove<F: Feature>: GlobalMutationRequest
{
    public
    var feature: Feature.Type
    {
        return F.self
    }
    
    public
    init() { }
}
