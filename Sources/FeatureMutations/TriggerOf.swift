import XCERequirement

//===

public
extension Feature
{
    static
    var trigger: TriggerOf<Self>.Type
    {
        return TriggerOf<Self>.self
    }
}

//===

public
enum TriggerOf<F: Feature>
{
    public
    enum NoState { }
    
    public
    typealias Uninitialized = NoState
    
    public
    enum AnyState { }
    
    public
    typealias Initialized = AnyState
    
    public
    enum In<S: FeatureState> where S.ParentFeature == F { }
    // swiftlint:disable:previous type_name
}

//===

public
extension TriggerOf.NoState
{
    static
    func via(
        scope: String = #file,
        context: String = #function,
        body: @escaping (NewModel, @escaping SubmitAction) throws -> Void
        ) -> Action
    {
        return Action(scope, context, self) { model, submit in
            
            try Require("\(F.name) is NOT presented yet").isNil(
                
                model >> F.self
            )
            
            //===
            
            try body(model, submit)
            
            //===
            
            return nil
        }
    }
}

//===

public
extension TriggerOf.AnyState
{
    static
    func via(
        scope: String = #file,
        context: String = #function,
        body: @escaping (NewModel, @escaping SubmitAction) throws -> Void
        ) -> Action
    {
        return Action(scope, context, self) { model, submit in
            
            try Require("\(F.name) is presented").isNotNil(
                
                model >> F.self
            )
            
            //===
            
            try body(model, submit)
            
            //===
            
            return nil
        }
    }
}

//===

public
extension TriggerOf.In
{
    static
    func via(
        scope: String = #file,
        context: String = #function,
        body: @escaping (S, @escaping SubmitAction) throws -> Void
        ) -> Action
    {
        return Action(scope, context, self) { model, submit in
            
            let currentState =
                
            try Require("\(F.name) is in \(S.self) state").isNotNil(
                
                model >> S.self
            )
            
            //===
            
            try body(currentState, submit)
            
            //===
            
            return nil
        }
    }
}
