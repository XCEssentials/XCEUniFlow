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
