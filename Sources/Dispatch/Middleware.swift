public
extension Dispatcher
{
    typealias Middleware = (GlobalMutation, GlobalModel, SubmitAction) -> Void
}

//===

public
extension Dispatcher
{
    @discardableResult
    func register(_ middlewareList: [Dispatcher.Middleware]) -> Self
    {
        middlewareList.forEach { self.middleware.append($0) }
        
        //===
        
        return self
    }
    
    @discardableResult
    func register(_ middleware: Dispatcher.Middleware...) -> Self
    {
        return register(middleware)
    }
    
    @discardableResult
    func register(_ listOfMiddlewareLists: [[Dispatcher.Middleware]]) -> Self
    {
        return register( listOfMiddlewareLists.joined().map({ $0 }) )
    }
}

//===

@discardableResult
public
func << (dispatcher: Dispatcher,
         middlewareList: [Dispatcher.Middleware]) -> Dispatcher
{
    dispatcher.register(middlewareList)
    
    //===
    
    return dispatcher
}

@discardableResult
public
func << (dispatcher: Dispatcher,
         middleware: @escaping Dispatcher.Middleware) -> Dispatcher
{
    dispatcher.register(middleware)
    
    //===
    
    return dispatcher
}

@discardableResult
public
func << (dispatcher: Dispatcher,
         listOfMiddlewareLists: [[Dispatcher.Middleware]]) -> Dispatcher
{
    dispatcher.register(listOfMiddlewareLists)
    
    //===
    
    return dispatcher
}
