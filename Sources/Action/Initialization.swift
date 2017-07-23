import XCERequirement

//===

public
extension Feature
{
    static
    var initialization: Initialization<Self>.Type
    {
        return Initialization<Self>.self
    }
}

//===

public
enum Initialization<F: Feature>
{
    public
    enum Into<S: FeatureState> where S.ParentFeature == F { }
}

//===

public
extension Initialization.Into where S: SimpleState
{
    static
    func automatic(
        action: String = #function,
        // submit
        completion: ((@escaping Wrapped<ActionGetter>) -> Void)? = nil
        ) -> Action
    {
        return Action(name: action, feature: F.self) { model, submit in
            
            try REQ.isNil("\(F.name) is NOT initialized yet") {
                
                model ==> F.self
            }
            
            //===
            
            completion?(submit)
            
            //===
            
            return { $0 <== S.init() }
        }
    }
}

//===

public
extension Initialization.Into
{
    static
    func via(
        action: String = #function,
        // become, submit
        body: @escaping (Wrapped<StateGetter<S>>, @escaping Wrapped<ActionGetter>) throws -> Void
        ) -> Action
    {
        return Action(name: action, feature: F.self) { model, submit in
            
            try REQ.isNil("\(F.name) is NOT initialized yet") {
                
                model ==> F.self
            }
            
            //===
            
            var newState: S!
            
            //===
            
            // http://alisoftware.github.io/swift/closures/2016/07/25/closure-capture-1/
            // capture 'var' value by reference here!
            
            try body({ newState = $0() }, submit)
            
            //===
            
            return { $0 <== newState }
        }
    }
}
