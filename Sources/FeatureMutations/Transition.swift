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
    struct Into<S: FeatureState> where S.ParentFeature == F
    {
        public
        let newState: S
    }
    
    public
    struct From<S: FeatureState> where S.ParentFeature == F
    {
        public
        let oldState: S
    }
    
    public
    struct Between<From: FeatureState, Into: FeatureState> where
        From.ParentFeature == F,
        Into.ParentFeature == F
    {
        public
        let oldState: From
        
        public
        let newState: Into
    }
    
    //===
    
    public
    let oldState: FeatureRepresentation
    
    public
    let newState: FeatureRepresentation
    
    init<Into>(from oldState: FeatureRepresentation, into newState: Into) where
        Into: FeatureState,
        Into.ParentFeature == F
    {
        self.oldState = oldState
        self.newState = newState
    }
}

public
typealias TransitionInto<S: FeatureState> = TransitionOf<S.ParentFeature>.Into<S>

public
typealias TransitionFrom<S: FeatureState> = TransitionOf<S.ParentFeature>.From<S>

#if swift(>=3.2)
    
public
typealias TransitionBetween<From: FeatureState, Into: FeatureState> =
    TransitionOf<From.ParentFeature>.Between<From, Into>
    where From.ParentFeature == Into.ParentFeature
    
#endif

//===

public
extension TransitionOf.Into
{
    static
    func via(
        scope: String = #file,
        context: String = #function,
        body: @escaping (NewModel, Become<S>, @escaping SubmitAction) throws -> Void
        ) -> Action
    {
        return Action(scope, context, self) { model, submit in
            
            let oldState =
                
            try Require("\(F.name) is presented").isNotNil(
                
                model >> F.self
            )
            
            //===
            
            var newState: S!
            
            //===
            
            try body(model, { newState = $0 }, submit)
            
            //===
            
            try Require("New state for \(F.name) is set").isNotNil(
                
                newState
            )
            
            //===
            
//            return (
//                { $0 << newState },
//                TransitionOf<F>(oldState: oldState, newState: newState)
//            )
//            return [ Store(state: newState) ]
            return [ TransitionOf(from: oldState, into: newState) ]
        }
    }
}

//===

public
extension TransitionOf.Into where S: SimpleState
{
    static
    func automatic(
        scope: String = #file,
        context: String = #function,
        completion: ((@escaping SubmitAction) -> Void)? = nil
        ) -> Action
    {
        return Action(scope, context, self) { model, submit in
            
            let oldState =
                
            try Require("\(F.name) is presented").isNotNil(
                
                model >> F.self
            )
            
            //===
            
            let newState = S.init()
            
            //===
            
            completion?(submit)
            
            //===
            
//            return (
//                { $0 << newState },
//                TransitionOf<F>(oldState: oldState, newState: newState)
//            )
//            return [ Store(state: newState) ]
            return [ TransitionOf(from: oldState, into: newState) ]
        }
    }
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
            
            try Require("\(F.name) is in \(S.self) state").isNotNil(
                
                model >> S.self
            )
            
            //===
            
//            return (
//                { $0 << newState },
//                TransitionOf<F>(oldState: oldState, newState: newState)
//            )
            return [ TransitionOf(from: oldState, into: newState) ]
        }
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
        completion: ((@escaping SubmitAction) -> Void)? = nil
        ) -> Action
    {
        return Action(scope, context, self) { model, submit in
            
            let oldState =
                
            try Require("\(F.name) is in \(From.self) state").isNotNil(
                
                model >> From.self
            )
            
            //===
            
            let newState = Into.init()
            
            //===
            
            completion?(submit)
            
            //===
            
//            return (
//                { $0 << newState },
//                TransitionOf<F>(oldState: oldState, newState: newState)
//            )
//            return [ Store(state: newState) ]
            return [ TransitionOf(from: oldState, into: newState) ]
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
        body: @escaping (From, Become<Into>, @escaping SubmitAction) throws -> Void
        ) -> Action
    {
        return Action(scope, context, self) { model, submit in
            
            let oldState =
                
            try Require("\(F.name) is in \(From.self) state").isNotNil(
                
                model >> From.self
            )
            
            //===
            
            var newState: Into!
            
            //===
            
            try body(oldState, { newState = $0 }, submit)
            
            //===
            
            try Require("New state for \(F.name) is set").isNotNil(
                
                newState
            )
            
            //===
            
//            return (
//                { $0 << newState },
//                TransitionOf<F>(oldState: oldState, newState: newState)
//            )
//            return [ Store(state: newState) ]
            return [ TransitionOf(from: oldState, into: newState) ]
        }
    }
}
