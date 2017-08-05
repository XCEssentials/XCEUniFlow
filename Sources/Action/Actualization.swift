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

extension Actualization: FeatureMutation
{
    public
    static
    var feature: Feature.Type { return F.self }
}

//===

public
extension Actualization.Of
{
    static
    func via(
        action: String = #function,
        // currentState, mutate, submit
        body: @escaping (S, Wrapped<Mutations<S>>, @escaping Wrapped<ActionGetter>) throws -> Void
        ) -> Action
    {
        return Action(name: action, feature: F.self) { model, submit in
            
            var state =
                
            try REQ.value("\(F.name) is in \(S.self) state") {
                
                model ==> S.self
            }
            
            //===
            
            try body(state, { $0(&state) }, submit)
            
            //===
            
            return ({ $0 <== state }, Actualization<F>.self)
        }
    }
}
