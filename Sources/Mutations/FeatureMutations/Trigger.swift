import XCERequirement

//===

public
extension Feature
{
    static
    var trigger: Trigger<Self>.Type
    {
        return Trigger<Self>.self
    }
}

//===

public
enum Trigger<F: Feature>
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
extension Trigger.NoState
{
    static
    func via(
        scope: String = #file,
        context: String = #function,
        // model, submit
        body: @escaping (GlobalModel, @escaping Wrapped<ActionGetter>) throws -> Void
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
extension Trigger.AnyState
{
    static
    func via(
        scope: String = #file,
        context: String = #function,
        // model, submit
        body: @escaping (GlobalModel, @escaping Wrapped<ActionGetter>) throws -> Void
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
extension Trigger.In
{
    static
    func via(
        scope: String = #file,
        context: String = #function,
        // currentState, submit
        body: @escaping (S, @escaping Wrapped<ActionGetter>) throws -> Void
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
