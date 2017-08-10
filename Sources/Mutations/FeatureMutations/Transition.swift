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
struct TransitionOf<F: Feature>
{
    public
    enum From<From: FeatureState> where From.ParentFeature == F { }
    
    public
    struct Between<From: FeatureState, Into: FeatureState> where
        From.ParentFeature == F,
        Into.ParentFeature == F
    { }
    
    //===
    
    public
    let oldState: Any
    
    public
    let newState: Any
}

public
struct TransitionFrom<S: FeatureState>
{
    public
    let oldState: S
}

public
struct TransitionInto<S: FeatureState>
{
    public
    let newState: S
}

//===

public
extension TransitionOf.From
{
    static
    func into<Into: FeatureState>(
        scope: String = #file,
        context: String = #function,
        _ newState: Into
        ) -> Action
        where Into.ParentFeature == F
    {
        return Action(scope, context, self) { model, _ in
            
            let oldState =
            
            try REQ.value("\(F.name) is in \(From.self) state") {
                
                model >> From.self
            }
            
            //===
            
            return (
                { $0 << newState },
                TransitionOf<F>(oldState: oldState, newState: newState)
            )
        }
    }
    
    static
    func into<Into: FeatureState>(
        scope: String = #file,
        context: String = #function,
        newStateGetter: () -> Into
        ) -> Action
        where Into.ParentFeature == F
    {
        let newState = newStateGetter()
        
        //===
        
        return into(scope: scope, context: context, newState)
    }
}

//===

public
extension TransitionOf.Between where Into: SimpleState
{
    static
    func automatic(
        scope: String = #file,
        context: String = #function,
        // submit
        completion: ((@escaping Wrapped<ActionGetter>) -> Void)? = nil
        ) -> Action
    {
        return Action(scope, context, self) { model, submit in
            
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
                TransitionOf<F>(oldState: oldState, newState: newState)
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
        scope: String = #file,
        context: String = #function,
        // currentState, become, submit
        body: @escaping (From, Wrapped<StateGetter<Into>>, @escaping Wrapped<ActionGetter>) throws -> Void
        ) -> Action
    {
        return Action(scope, context, self) { model, submit in
            
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
                TransitionOf<F>(oldState: oldState, newState: newState)
            )
        }
    }
}
