import XCERequirement

//===

public
extension Feature
{
    static
    var actualization: Actualization<Self>.Type
    {
        return Actualization<Self>.self
    }
}

//===

public
enum Actualization<F: Feature>
{
    public
    enum Of<S: FeatureState> where S.ParentFeature == F { }
    // swiftlint:disable:previous type_name
}

//===

public
extension Actualization.Of
{
    public
    static
    func via(
        action: String = #function,
        body: @escaping (S, Wrapped<Mutations<S>>, @escaping Wrapped<ActionGetter>) throws -> Void
        ) -> Action
    {
        return Action(name: action, feature: F.self) { model, mutate, submit in
            
            let currentState =
                
            try REQ.value("\(S.ParentFeature.name) is in \(S.self) state") {
                
                model ==> S.self
            }
            
            //===
            
            var buf = currentState
            
            try body(currentState, { $0(&buf) }, submit)
            
            //===
            
            mutate { $0 <== buf }
        }
    }
}
