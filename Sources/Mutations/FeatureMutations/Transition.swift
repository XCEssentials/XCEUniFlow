import XCERequirement

//===

public
extension Feature
{
    static
    var transition: TransitionOf<Self>.Type
    {
        return TransitionOf<Self>.self
    }
}

//===

public
enum TransitionOf<F: Feature>
{
    public
    enum From<From: FeatureState> where From.ParentFeature == F { }
    
    public
    struct Between<From: FeatureState, Into: FeatureState> where
        From.ParentFeature == F,
        Into.ParentFeature == F
    {
        let oldState: From
        let newState: Into
    }
}

//===

public
extension TransitionOf.From
{
    static
    func into<Into: FeatureState>(
        action: String = #function,
        _ newState: Into
        ) -> Action
        where Into.ParentFeature == F
    {
        return Action(name: action, context: F.self) { model, _ in
            
            let oldState =
            
            try REQ.value("\(F.name) is in \(From.self) state") {
                
                model >> From.self
            }
            
            //===
            
            return (
                { $0 << newState },
                TransitionOf<F>.Between(oldState: oldState, newState: newState)
            )
        }
    }
}

//===

public
extension TransitionOf.Between where Into: SimpleState
{
    static
    func automatic(
        action: String = #function,
        // submit
        completion: ((@escaping Wrapped<ActionGetter>) -> Void)? = nil
        ) -> Action
    {
        return Action(name: action, context: F.self) { model, submit in
            
            let oldState =
                
            try REQ.value("\(F.name) is in \(From.self) state") {
                
                model >> From.self
            }
            
            //===
            
            let newState = Into.init()
            
            //===
            
            completion?(submit)
            
            //===
            
            return (
                { $0 << newState },
                self.init(oldState: oldState, newState: newState)
            )
        }
    }
}

//===

public
extension TransitionOf.Between
{
    static
    func via(
        action: String = #function,
        // currentState, become, submit
        body: @escaping (From, Wrapped<StateGetter<Into>>, @escaping Wrapped<ActionGetter>) throws -> Void
        ) -> Action
    {
        return Action(name: action, context: F.self) { model, submit in
            
            let oldState =
                
            try REQ.value("\(F.name) is in \(From.self) state") {
                
                model >> From.self
            }
            
            //===
            
            var newState: Into!
            
            //===
            
            try body(oldState, { newState = $0() }, submit)
            
            //===
            
            try REQ.isNotNil("New state for \(F.name) is set") {
                
                newState
            }
            
            //===
            
            return (
                { $0 << newState },
                self.init(oldState: oldState, newState: newState)
            )
        }
    }
}
