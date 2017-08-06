public
protocol ActionDescription { }

//===

public
extension ActionDescription
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
    func isEqual(to anotherType: ActionDescription.Type) -> Bool
    {
        return anotherType == Self.self
    }
}

//===

public
enum UnspecifiedMutation: ActionDescription { } // maybe multiple mutations???

//===

public
protocol FeatureMutation: ActionDescription
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
