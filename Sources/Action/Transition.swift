import XCERequirement

//===

public
extension Feature
{
    static
    var transition: Transition<Self>.Type
    {
        return Transition<Self>.self
    }
}

//===

public
enum Transition<F: Feature>
{
    public
    enum Between<From: FeatureState, Into: FeatureState> where
        From.ParentFeature == F,
        Into.ParentFeature == F
    { }
}

//===

public
extension Transition.Between where Into: SimpleState
{
    public
    static
    func automatic(
        action: String = #function,
        completion: ((@escaping Wrapped<ActionGetter>) throws -> Void)? = nil
        ) -> Action
    {
        return Action(name: action, feature: F.self) { model, mutate, submit in
            
            try REQ.isNotNil("\(From.ParentFeature.name) is in \(From.self) state") {
                
                model ==> From.self
            }
            
            //===
            
            mutate { $0 <== Into.init() }
            
            //===
            
            try completion?(submit)
        }
    }
}

//===

public
extension Transition.Between
{
    public
    static
    func via(
        action: String = #function,
        body: @escaping (From, Wrapped<StateGetter<Into>>, @escaping Wrapped<ActionGetter>) throws -> Void
        ) -> Action
    {
        return Action(name: action, feature: F.self) { model, mutate, submit in
            
            let currentState =
                
            try REQ.value("\(From.ParentFeature.name) is in \(From.self) state") {
                
                model ==> From.self
            }
            
            //===
            
            var newState: Into?
            
            try body(currentState, { newState = $0() }, submit)
            
            //===
            
            try REQ.isNotNil("New state for \(Into.ParentFeature.name) is set") {
                
                newState
            }
            
            //===
            
            mutate { $0 <== newState }
        }
    }
}
