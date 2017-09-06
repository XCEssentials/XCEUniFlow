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
struct DeinitializationOf<F: Feature>: ApplyDiff
{
    public
    struct From<S: FeatureState> where S.ParentFeature == F
    {
        public
        let oldState: S
    }
    
    //===
    
    public
    let oldState: FeatureRepresentation
    
    let apply: (GlobalModel) -> GlobalModel.MutationResult?
    
    //===
    
    init(from oldState: FeatureRepresentation)
    {
        self.oldState = oldState
        self.apply = { $0.removeRepresentation(ofFeature: F.self) }
    }
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
        completion: ((@escaping SubmitAction) -> Void)? = nil
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
            
//            return ({ $0 /< F.self }, DeinitializationOf<F>(oldState: oldState))
//            return [ Remove(feature: F.self) ]
            return [ DeinitializationOf(from: oldState) ]
        }
    }
    
    //===
    
    static
    func prepare(
        scope: String = #file,
        context: String = #function,
        body: @escaping (GlobalModel, @escaping SubmitAction) throws -> Void
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
            
//            return ({ $0 /< F.self }, DeinitializationOf<F>(oldState: oldState))
//            return [ Remove(feature: F.self) ]
            return [ DeinitializationOf(from: oldState) ]
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
        completion: ((@escaping SubmitAction) -> Void)? = nil
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
            
//            return ({ $0 /< F.self }, DeinitializationOf<F>(oldState: oldState))
//            return [ Remove(feature: F.self) ]
            return [ DeinitializationOf(from: oldState) ]
        }
    }
    
    //===
    
    static
    func prepare(
        scope: String = #file,
        context: String = #function,
        body: @escaping (S, @escaping SubmitAction) throws -> Void
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
            
//            return ({ $0 /< F.self }, DeinitializationOf<F>(oldState: oldState))
//            return [ Remove(feature: F.self) ]
            return [ DeinitializationOf(from: oldState) ]
        }
    }
}
