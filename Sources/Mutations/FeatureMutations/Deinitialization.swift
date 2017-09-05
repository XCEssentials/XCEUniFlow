import XCERequirement

//===

public
extension Feature
{
    static
    var deinitialization: DeinitializationOf<Self>.Type
    {
        return DeinitializationOf<Self>.self
    }
}

//===

public
struct DeinitializationOf<F: Feature>
{
    public
    struct From<S: FeatureState> where S.ParentFeature == F
    {
        public
        let oldState: S
    }
    
    //===
    
    public
    let oldState: Any
}

public
typealias DeinitializationFrom<S: FeatureState> = DeinitializationOf<S.ParentFeature>.From<S>

//===

public
extension DeinitializationOf
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
            
            let oldState =
                
            try Require("\(F.name) is presented").isNotNil(
                
                model >> F.self
            )
            
            //===
            
            completion?(submit)
            
            //===
            
            return ({ $0 /< F.self }, DeinitializationOf<F>(oldState: oldState))
        }
    }
    
    //===
    
    static
    func prepare(
        scope: String = #file,
        context: String = #function,
        // model, submit
        body: @escaping (GlobalModel, @escaping Wrapped<ActionGetter>) throws -> Void
        ) -> Action
    {
        return Action(scope, context, self) { model, submit in
            
            let oldState =
                
            try Require("\(F.name) is presented").isNotNil(
                
                model >> F.self
            )
            
            //===
            
            try body(model, submit)
            
            //===
            
            return ({ $0 /< F.self }, DeinitializationOf<F>(oldState: oldState))
        }
    }
}

//===

public
extension DeinitializationOf.From
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
            
            let oldState =
                
            try Require("\(F.name) is in \(S.self) state").isNotNil(
                
                model >> S.self
            )
            
            //===
            
            completion?(submit)
            
            //===
            
            return ({ $0 /< F.self }, DeinitializationOf<F>(oldState: oldState))
        }
    }
    
    //===
    
    static
    func prepare(
        scope: String = #file,
        context: String = #function,
        // currentState, submit
        body: @escaping (S, @escaping Wrapped<ActionGetter>) throws -> Void
        ) -> Action
    {
        return Action(scope, context, self) { model, submit in
            
            let oldState =
                
            try Require("\(F.name) is in \(S.self) state").isNotNil(
                
                model >> S.self
            )
            
            //===
            
            try body(oldState, submit)
            
            //===
            
            return ({ $0 /< F.self }, DeinitializationOf<F>(oldState: oldState))
        }
    }
}
