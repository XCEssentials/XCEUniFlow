public
protocol MutationAnnotation { }

//===

public
extension MutationAnnotation
{
    static
    var isFeatureMutation: Bool
    {
        return self is FeatureMutation.Type
    }
    
    static
    var asFeatureMutation: FeatureMutation.Type?
    {
        return self as? FeatureMutation.Type
    }
    
    static
        func isEqual(to anotherType: MutationAnnotation.Type) -> Bool
    {
        return anotherType == Self.self
    }
}

//===

public
enum NoMutation: MutationAnnotation { }

//===

public
enum UnspecifiedMutation: MutationAnnotation { } // maybe multiple mutations???

//===

public
protocol FeatureMutation: MutationAnnotation
{
    static
    var feature: Feature.Type { get }
}

// MARK: FeatureMutation variants

extension InitializationOf: FeatureMutation
{
    public
    static
    var feature: Feature.Type { return F.self }
}

//===

extension ActualizationOf: FeatureMutation
{
    public
    static
    var feature: Feature.Type { return F.self }
}

//===

extension TransitionOf: FeatureMutation
{
    public
    static
    var feature: Feature.Type { return F.self }
}

//===

extension DeinitializationOf: FeatureMutation
{
    public
    static
    var feature: Feature.Type { return F.self }
}
