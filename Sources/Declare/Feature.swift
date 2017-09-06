public
protocol Feature
{
    static
    var middleware: [Dispatcher.Middleware] { get }
}

//===

public
extension Feature
{
    static
    var middleware: [Dispatcher.Middleware]
    {
        return []
    }
}

//===

public
extension Feature
{
    static
    var name: String
    {
        return String(reflecting: self)
    }
}
