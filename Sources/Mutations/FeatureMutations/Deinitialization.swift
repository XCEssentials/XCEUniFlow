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
        let oldState: S
    }
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
        return Action(name: action, context: self) { _, submit in
            
             completion?(submit)
            
            //===
            
            return ({ $0 /< F.self }, self.init())
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
        return Action(name: action, context: self) { model, submit in
            
            try body(model, submit)
            
            //===
            
            return ({ $0 /< F.self }, self.init())
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
        return Action(name: action, context: self) { model, submit in
            
            let oldState =
                
            try REQ.value("\(F.name) is in \(S.self) state") {
                
                model >> S.self
            }
            
            //===
            
            completion?(submit)
            
            //===
            
            return ({ $0 /< F.self }, self.init(oldState: oldState))
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
        return Action(name: action, context: self) { model, submit in
            
            let oldState =
                
            try REQ.value("\(F.name) is in \(S.self) state") {
                
                model >> S.self
            }
            
            //===
            
            try body(oldState, submit)
            
            //===
            
            return ({ $0 /< F.self }, self.init(oldState: oldState))
        }
    }
}
