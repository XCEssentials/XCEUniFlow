public
protocol FeatureRepresentation
{
    /**
     Feature to which this mutation is related.
     */
    static
    var feature: Feature.Type { get }
}

//===

public
protocol FeatureState: FeatureRepresentation
{
    associatedtype ParentFeature: Feature
}

//===

public
extension FeatureState
{
    static
    var feature: Feature.Type { return ParentFeature.self }
}

//===

public
protocol SimpleState: FeatureState
{
    init()
}
