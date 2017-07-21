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
    func automatic(
        action: String = #function
        ) -> Action
    {
        return Action(name: action, feature: F.self) { _, mutate, _ in
            
            _ = 0 // Xcode bug workaround
            
            mutate{ $0 /== F.self }
        }
    }
    
    //===
    
    public
    static
    func prepare(
        action: String = #function,
        body: @escaping (GlobalModel, @escaping Wrapped<ActionGetter>) throws -> Void
        ) -> Action
    {
        return Action(name: action, feature: F.self) { model, mutate, submit in
            
            try body(model, submit)
            
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
    func automatic(
        action: String = #function
        ) -> Action
    {
        return Action(name: action, feature: F.self) { model, mutate, _ in
            
            try REQ.isNotNil("\(S.ParentFeature.name) is in \(S.self) state") {
                
                model ==> S.self
            }
            
            //===
            
            mutate{ $0 /== S.ParentFeature.self }
        }
    }
    
    //===
    
    public
    static
    func prepare(
        action: String = #function,
        body: @escaping (S, @escaping Wrapped<ActionGetter>) throws -> Void
        ) -> Action
    {
        return Action(name: action, feature: F.self) { model, mutate, submit in
            
            let currentState =
                
            try REQ.value("\(S.ParentFeature.name) is in \(S.self) state") {
                
                model ==> S.self
            }
            
            //===
            
            try body(currentState, submit)
            
            //===
            
            mutate{ $0 /== S.ParentFeature.self }
        }
    }
}
