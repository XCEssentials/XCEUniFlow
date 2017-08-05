public
protocol DispatcherInitializable: class
{
    init(with proxy: Dispatcher.Proxy)
}

//===

public
protocol DispatcherBindable: class
{
    func bind(with proxy: Dispatcher.Proxy) -> Self
}

//===

public
protocol Feature {}

public
extension Feature
{
    static
    var name: String { return String(reflecting: Self.self) }
}

//===

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

//===

public
protocol MutationAnnotation { }

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
protocol FeatureMutation: MutationAnnotation
{
    static
    var feature: Feature.Type { get }
    
}
