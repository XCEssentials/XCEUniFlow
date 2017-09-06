public
protocol FeatureRepresentation { } // SomeFeatureState ?? AnyFeatureState ??

//===

public
protocol FeatureState: FeatureRepresentation
{
    associatedtype ParentFeature: Feature
}

//===

public
protocol SimpleState: FeatureState
{
    init()
}
