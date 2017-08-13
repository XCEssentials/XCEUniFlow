public
protocol Middleware
{
    var mutation: GlobalDiff { get }
    
//    //===
//
//    public
//    init()
//    {
//        //
//    }
}

//===

public
extension Middleware
{
    func update(model: GlobalModel,
                submit: @escaping Wrapped<ActionGetter>)
    {
        //
    }
}
