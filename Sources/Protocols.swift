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

//===

public
protocol FeatureMutation: MutationAnnotation
{
    static
    var feature: Feature.Type { get }
    
}
