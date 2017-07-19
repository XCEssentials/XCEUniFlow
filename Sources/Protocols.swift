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
protocol Feature: ActionContext {}

//===

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
