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
        return Action(name: action, feature: F.self) { _, _ in
            
            _ = 0 // Xcode bug workaround
            
            return { $0 /== F.self }
        }
    }
    
    //===
    
    public
    static
    func prepare(
        action: String = #function,
        // model, submit
        body: @escaping (GlobalModel, @escaping Wrapped<ActionGetter>) throws -> Void
        ) -> Action
    {
        return Action(name: action, feature: F.self) { model, submit in
            
            try body(model, submit)
            
            //===
            
            return { $0 /== F.self }
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
        return Action(name: action, feature: F.self) { model, _ in
            
            try REQ.isNotNil("\(F.name) is in \(S.self) state") {
                
                model ==> S.self
            }
            
            //===
            
            return { $0 /== F.self }
        }
    }
    
    //===
    
    public
    static
    func prepare(
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
            
            return { $0 /== F.self }
        }
    }
}
