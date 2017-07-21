import XCERequirement

//===

public
extension Feature
{
    static
    var deinitialization: Deinitialization<Self>.Type
    {
        return Deinitialization<Self>.self
    }
}

//===

public
enum Deinitialization<F: Feature>
{
    public
    enum From<S: FeatureState> where S.ParentFeature == F { }
}

//===

public
extension Deinitialization
{
    public
    static
    func unconditional(
        action: String = #function,
        completion: ((@escaping Wrapped<ActionGetter>) throws -> Void)?
        ) -> Action
    {
        return Action(name: action, feature: F.self) { _, mutate, submit in
            
            try completion?(submit)
            
            //===
            
            mutate{ $0 /== F.self }
        }
    }
}

//===

public
extension Deinitialization.From
{
    public
    static
    func via(
        action: String = #function,
        body: ((S, @escaping Wrapped<ActionGetter>) throws -> Void)?
        ) -> Action
    {
        return Action(name: action, feature: F.self) { model, mutate, submit in
            
            let currentState =
                
            try REQ.value("\(S.ParentFeature.name) is in \(S.self) state") {
                
                model ==> S.self
            }
            
            //===
            
            try body?(currentState, submit)
            
            //===
            
            mutate{ $0 /== S.ParentFeature.self }
        }
    }
}
