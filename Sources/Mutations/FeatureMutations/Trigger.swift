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
            
            try REQ.isNil("\(F.name) is NOT presented yet") {
                
                model >> F.self
            }
            
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
            
            try REQ.isNotNil("\(F.name) is presented") {
                
                model >> F.self
            }
            
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
                
            try REQ.value("\(F.name) is in \(S.self) state") {
                
                model >> S.self
            }
            
            //===
            
            try body(currentState, submit)
            
            //===
            
            return nil
        }
    }
}
