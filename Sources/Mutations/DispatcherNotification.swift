public
protocol DispatcherNotification { }

//===

public
extension DispatcherNotification
{
    static
    var isFeatureMutation: Bool
    {
        return self is FeatureMutation.Type
    }
    
    static
    func isMutation(of feature: Feature.Type) -> Bool
    {
        return asFeatureMutation?.feature == feature
    }
    
    static
    var asFeatureMutation: FeatureMutation.Type?
    {
        return self as? FeatureMutation.Type
    }
    
    static
    func isEqual(to anotherType: DispatcherNotification.Type) -> Bool
    {
        return anotherType == Self.self
    }
}

//===

public
enum InitialUpdate: DispatcherNotification { }

//===

public
enum UnspecifiedMutation: DispatcherNotification { } // maybe multiple mutations???

//===

public
protocol FeatureMutation: DispatcherNotification
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
