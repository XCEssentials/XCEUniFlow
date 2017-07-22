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
    enum On<S: FeatureState> where S.ParentFeature == F { }
    // swiftlint:disable:previous type_name
}

//===

public
extension Trigger
{
    public
    static
    func via(
        action: String = #function,
        // model, submit
        body: @escaping (GlobalModel, @escaping Wrapped<ActionGetter>) throws -> Void
        ) -> Action
    {
        return Action(name: action, feature: F.self) { model, submit in
            
            try body(model, submit)
            
            //===
            
            return nil
        }
    }
}

//===

public
extension Trigger.On
{
    public
    static
    func via(
        action: String = #function,
        // currentState, submit
        body: @escaping (S, @escaping Wrapped<ActionGetter>) throws -> Void
        ) -> Action
    {
        return Action(name: action, feature: F.self) { model, submit in
            
            let currentState =
                
            try REQ.value("\(F.name) is in \(S.self) state") {
                
                model ==> S.self
            }
            
            //===
            
            try body(currentState, submit)
            
            //===
            
            return nil
        }
    }
}
