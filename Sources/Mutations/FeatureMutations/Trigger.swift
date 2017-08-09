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
    enum WithoutState { }
    
    public
    enum In<S: FeatureState> where S.ParentFeature == F { }
    // swiftlint:disable:previous type_name
}

//===

public
extension Trigger.WithoutState
{
    static
    func via(
        action: String = #function,
        // model, submit
        body: @escaping (GlobalModel, @escaping Wrapped<ActionGetter>) throws -> Void
        ) -> Action
    {
        return Action(name: action, context: self) { model, submit in
            
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
extension Trigger.In
{
    static
    func via(
        action: String = #function,
        // currentState, submit
        body: @escaping (S, @escaping Wrapped<ActionGetter>) throws -> Void
        ) -> Action
    {
        return Action(name: action, context: self) { model, submit in
            
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
