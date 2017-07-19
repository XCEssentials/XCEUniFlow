public
protocol FeatureState
{
    associatedtype UFLFeature: Feature
}

//===

public
protocol SimpleState: FeatureState
{
    init()
}
