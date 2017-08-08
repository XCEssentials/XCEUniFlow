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
enum DeinitializationOf<F: Feature>
{
    public
    enum From<S: FeatureState> where S.ParentFeature == F { }
}

//===

public
extension DeinitializationOf
{
    static
    func automatic(
        action: String = #function,
        // submit
        completion: ((@escaping Wrapped<ActionGetter>) -> Void)? = nil
        ) -> Action
    {
        return Action(name: action, context: F.self) { _, submit in
            
            completion?(submit)
            
            //===
            
            return ({ $0 /< F.self }, DeinitializationOf<F>.self)
        }
    }
    
    //===
    
    static
    func prepare(
        action: String = #function,
        // model, submit
        body: @escaping (GlobalModel, @escaping Wrapped<ActionGetter>) throws -> Void
        ) -> Action
    {
        return Action(name: action, context: F.self) { model, submit in
            
            try body(model, submit)
            
            //===
            
            return ({ $0 /< F.self }, DeinitializationOf<F>.self)
        }
    }
}

//===

public
extension DeinitializationOf.From
{
    static
    func automatic(
        action: String = #function,
        // submit
        completion: ((@escaping Wrapped<ActionGetter>) -> Void)? = nil
        ) -> Action
    {
        return Action(name: action, context: F.self) { model, submit in
            
            try REQ.isNotNil("\(F.name) is in \(S.self) state") {
                
                model >> S.self
            }
            
            //===
            
            completion?(submit)
            
            //===
            
            return ({ $0 /< F.self }, DeinitializationOf<F>.self)
        }
    }
    
    //===
    
    static
    func prepare(
        action: String = #function,
        // currentState, submit
        body: @escaping (S, @escaping Wrapped<ActionGetter>) throws -> Void
        ) -> Action
    {
        return Action(name: action, context: F.self) { model, submit in
            
            let currentState =
                
            try REQ.value("\(F.name) is in \(S.self) state") {
                
                model >> S.self
            }
            
            //===
            
            try body(currentState, submit)
            
            //===
            
            return ({ $0 /< F.self }, DeinitializationOf<F>.self)
        }
    }
}
