public
protocol FeatureState
{
    associatedtype ParentFeature: Feature
}

//===

public
protocol SimpleState: FeatureState
{
    init()
}
