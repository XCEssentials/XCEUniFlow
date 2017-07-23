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
    static
    func automatic(
        action: String = #function,
        // submit
        completion: ((@escaping Wrapped<ActionGetter>) -> Void)? = nil
        ) -> Action
    {
        return Action(name: action, feature: F.self) { model, submit in
            
            try REQ.isNotNil("\(F.name) is in \(From.self) state") {
                
                model ==> From.self
            }
            
            //===
            
            completion?(submit)
            
            //===
            
            return { $0 <== Into.init() }
        }
    }
}

//===

public
extension Transition.Between
{
    static
    func via(
        action: String = #function,
        // currentState, become, submit
        body: @escaping (From, Wrapped<StateGetter<Into>>, @escaping Wrapped<ActionGetter>) throws -> Void
        ) -> Action
    {
        return Action(name: action, feature: F.self) { model, submit in
            
            let currentState =
                
            try REQ.value("\(F.name) is in \(From.self) state") {
                
                model ==> From.self
            }
            
            //===
            
            var newState: Into?
            
            //===
            
            try body(currentState, { newState = $0() }, submit)
            
            //===
            
            try REQ.isNotNil("New state for \(F.name) is set") {
                
                newState
            }
            
            //===
            
            return { $0 <== newState }
        }
    }
}
