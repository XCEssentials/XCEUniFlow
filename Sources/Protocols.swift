public
protocol DispatcherInitializable: class
{
    init(with proxy: DispatcherProxy)
}

//===

public
protocol DispatcherBindable: class
{
    func bind(with proxy: DispatcherProxy) -> Self
}
