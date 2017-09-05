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
struct InitializationOf<F: Feature>
{
    public
    struct Into<S: FeatureState> where S.ParentFeature == F
    {
        public
        let newState: S
    }
    
    //===
    
    public
    let newState: Any
}

public
typealias InitializationInto<S: FeatureState> = InitializationOf<S.ParentFeature>.Into<S>

//===

public
extension InitializationOf.Into where S: SimpleState
{
    static
    func automatic(
        scope: String = #file,
        context: String = #function,
        // submit
        completion: ((@escaping Wrapped<ActionGetter>) -> Void)? = nil
        ) -> Action
    {
        return Action(scope, context, self) { model, submit in
            
            try Require("\(F.name) is NOT initialized yet").isNil(
                
                model >> F.self
            )
            
            //===
            
            let newState = S.init()
            
            //===
            
            completion?(submit)
            
            //===
            
            return ({ $0 <<  newState}, InitializationOf<F>(newState: newState))
        }
    }
}

//===

public
extension InitializationOf.Into
{
    static
    func via(
        scope: String = #file,
        context: String = #function,
        // become, submit
        body: @escaping (Wrapped<StateGetter<S>>, @escaping Wrapped<ActionGetter>) throws -> Void
        ) -> Action
    {
        return Action(scope, context, self) { model, submit in
            
            try Require("\(F.name) is NOT initialized yet").isNil(
                
                model >> F.self
            )
            
            //===
            
            var newState: S!
            
            //===
            
            // http://alisoftware.github.io/swift/closures/2016/07/25/closure-capture-1/
            // capture 'var' value by reference here!
            
            try body({ newState = $0() }, submit)
            
            //===
            
            try Require("New state for \(F.name) is set").isNotNil(
                
                newState
            )
            
            //===
            
            return ({ $0 << newState }, InitializationOf<F>(newState: newState))
        }
    }
}
