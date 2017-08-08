public
protocol MutationsAnnotation { }

//===

public
extension Feature
{
    static
    func wasMutated(_ changes: MutationsAnnotation) -> Bool
    {
        return (changes as? FeatureMutation)?.feature == self
    }
}

//===

public
struct NoMutations: MutationsAnnotation { } // like initial update

//===

public
struct UnspecifiedMutation: MutationsAnnotation { } // maybe multiple mutations???

//===

public
protocol FeatureMutation: MutationsAnnotation
{
    var feature: Feature.Type { get }
    var currentState: Any? { get }
}

//===

public
protocol FeatureDeinitialization: FeatureMutation { }

//===

public
extension FeatureState
{
    static
    func wasMutated(_ changes: MutationsAnnotation) -> Self?
    {
        return (changes as? FeatureMutation)?.currentState as? Self
    }
}

// MARK: FeatureMutation variants

extension InitializationOf.Into: FeatureMutation
{
    public
    var feature: Feature.Type { return F.self }
    
    public
    var currentState: Any? { return newState }
}

//===

extension ActualizationOf.In: FeatureMutation
{
    public
    var feature: Feature.Type { return F.self }
    
    public
    var currentState: Any? { return state }
}

//===

extension TransitionOf.Between: FeatureMutation
{
    public
    var feature: Feature.Type { return F.self }
    
    public
    var currentState: Any? { return newState }
}

//===

extension DeinitializationOf: FeatureDeinitialization
{
    public
    var feature: Feature.Type { return F.self }
    
    public
    var currentState: Any? { return nil }
}

//===

extension DeinitializationOf.From: FeatureDeinitialization
{
    public
    var feature: Feature.Type { return F.self }
    
    public
    var currentState: Any? { return nil }
}
