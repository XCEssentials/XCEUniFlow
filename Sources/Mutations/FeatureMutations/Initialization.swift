import XCERequirement

//===

public
extension Feature
{
    static
    var initialization: InitializationOf<Self>.Type
    {
        return InitializationOf<Self>.self
    }
}

//===

public
enum InitializationOf<F: Feature>
{
    public
    enum Into<S: FeatureState> where S.ParentFeature == F { }
}

//===

public
extension InitializationOf.Into where S: SimpleState
{
    static
    func automatic(
        action: String = #function,
        // submit
        completion: ((@escaping Wrapped<ActionGetter>) -> Void)? = nil
        ) -> Action
    {
        return Action(name: action, context: F.self) { model, submit in
            
            try REQ.isNil("\(F.name) is NOT initialized yet") {
                
                model ==> F.self
            }
            
            //===
            
            completion?(submit)
            
            //===
            
            return ({ $0 <== S.init() }, InitializationOf<F>.self)
        }
    }
}

//===

public
extension InitializationOf.Into
{
    static
    func via(
        action: String = #function,
        // become, submit
        body: @escaping (Wrapped<StateGetter<S>>, @escaping Wrapped<ActionGetter>) throws -> Void
        ) -> Action
    {
        return Action(name: action, context: F.self) { model, submit in
            
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
            
            return ({ $0 <== newState }, InitializationOf<F>.self)
        }
    }
}
