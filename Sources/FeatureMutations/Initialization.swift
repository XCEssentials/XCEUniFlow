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
struct InitializationOf<F: Feature>: ApplyDiff
{
    public
    struct Into<S: FeatureState> where S.ParentFeature == F
    {
        public
        let newState: S
    }
    
    //===
    
    public
    let newState: FeatureRepresentation
    
    let apply: (GlobalModel) -> GlobalModel.MutationResult?
    
    //===
    
    init<S: FeatureState>(into newState: S) where S.ParentFeature == F
    {
        self.newState = newState
        self.apply = { $0.store(newState) }
    }
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
        completion: ((@escaping SubmitAction) -> Void)? = nil
        ) -> Action
    {
        return Action(scope, context, self) { model, submit in
            
            try Require("\(F.name) is NOT initialized yet").isNil(
                
                model >> F.self
            )
            
            //---
            
            let newState = S.init()
            
            //---
            
            completion?(submit)
            
            //---
            
//            return ({ $0 <<  newState}, InitializationOf<F>(newState: newState))
//            return [ Store(state: newState) ]
            return [ InitializationOf(into: newState) ]
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
        body: @escaping (Become<S>, @escaping SubmitAction) throws -> Void
        ) -> Action
    {
        return Action(scope, context, self) { model, submit in
            
            try Require("\(F.name) is NOT initialized yet").isNil(
                
                model >> F.self
            )
            
            //---
            
            var newState: S!
            
            //---
            
            try body({ newState = $0 }, submit)
            
            //---
            
            try Require("New state for \(F.name) is set").isNotNil(
                
                newState
            )
            
            //---
            
//            return ({ $0 << newState }, InitializationOf<F>(newState: newState))
//            return [ Store(state: newState) ]
            return [ InitializationOf(into: newState) ]
        }
    }
}
