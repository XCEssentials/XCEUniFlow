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

//===

public
extension Feature
{
    static
    var name: String { return String(reflecting: Self.self) }
    
    static
    func action(_ name: String = #function, body: @escaping ActionBody) -> Action
    {
        return GenericAction(name: "\(self.name).\(name)", body: body)
    }
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
protocol Action
{
    var name: String { get }
    
    var body: ActionBody { get }
}
