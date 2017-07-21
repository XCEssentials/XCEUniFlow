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
        body: @escaping (GlobalModel, @escaping Wrapped<ActionGetter>) throws -> Void
        ) -> Action
    {
        return Action(name: action, feature: F.self) { model, _, submit in
            
            try body(model, submit)
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
        body: @escaping (S, @escaping Wrapped<ActionGetter>) throws -> Void
        ) -> Action
    {
        return Action(name: action, feature: F.self) { model, _, submit in
            
            let currentState =
                
            try REQ.value("\(S.ParentFeature.name) is in \(S.self) state") {
                
                model ==> S.self
            }
            
            //===
            
            try body(currentState, submit)
        }
    }
}
