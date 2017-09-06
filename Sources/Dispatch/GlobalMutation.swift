public
protocol GlobalMutation
{
    /**
     Feature to which this mutation is related.
     */
    static
    var feature: Feature.Type { get }
}

protocol ApplyDiff
{
    var apply: (GlobalModel) -> GlobalModel.MutationResult? { get }
}

// MARK: - Initialization

extension InitializationOf: GlobalMutation
{
    public
    static
    var feature: Feature.Type { return F.self }
    
    //===
    
    // if let someAppState = InitializationOf<M.App>(diff)?.newState
    
    public
    init?(_ diff: GlobalMutation)
    {
        guard
            let mutation = diff as? InitializationOf<F>
        else
        {
            return nil
        }
        
        //===
        
        self = mutation
    }
}

//===

extension InitializationInto
{
    // if let appRunning = InitializationInto<M.App.Running>(diff)?.newState
    
    public
    init?(_ diff: GlobalMutation)
    {
        guard
            let mutation = diff as? InitializationOf<F>,
            let newState = mutation.newState as? S
        else
        {
            return nil
        }
        
        //===
        
        self = InitializationInto(newState: newState)
    }
}

// MARK: - Actualization

extension ActualizationOf: GlobalMutation
{
    public
    static
    var feature: Feature.Type { return F.self }
    
    //===
    
    // if let someAppState = ActualizationOf<M.App>(diff)?.state
    
    public
    init?(_ diff: GlobalMutation)
    {
        guard
            let mutation = diff as? ActualizationOf<F>
        else
        {
            return nil
        }
        
        //===
        
        self = mutation
    }
}

//===

extension ActualizationIn
{
    // if let appRunning = ActualizationIn<M.App.Running>(diff)?.state
    
    public
    init?(_ diff: GlobalMutation)
    {
        guard
            let mutation = diff as? ActualizationOf<F>,
            let state = mutation.state as? S
        else
        {
            return nil
        }
        
        //===
        
        self = ActualizationIn(state: state)
    }
}

// MARK: - Transition

extension TransitionOf: GlobalMutation
{
    public
    static
    var feature: Feature.Type { return F.self }
    
    //===
    
    // if let someOldAppState = TransitionOf<M.App>(diff)?.oldState
    // if let someNewAppState = TransitionOf<M.App>(diff)?.newState
    
    public
    init?(_ diff: GlobalMutation)
    {
        guard
            let mutation = diff as? TransitionOf<F>
        else
        {
            return nil
        }
        
        //===
        
        self = mutation
    }
}

//===

extension TransitionFrom
{
    // if let appRunning = TransitionFrom<M.App.Running>(diff)?.oldState
    
    public
    init?(_ diff: GlobalMutation)
    {
        guard
            let mutation = diff as? TransitionOf<S.ParentFeature>,
            let oldState = mutation.oldState as? S
        else
        {
            return nil
        }
        
        //===
        
        self = TransitionFrom(oldState: oldState)
    }
}

//===

extension TransitionInto
{
    // if let appRunning = TransitionInto<M.App.Running>(diff)?.newState
    
    public
    init?(_ diff: GlobalMutation)
    {
        guard
            let mutation = diff as? TransitionOf<S.ParentFeature>,
            let newState = mutation.newState as? S
        else
        {
            return nil
        }
        
        //===
        
        self = TransitionInto(newState: newState)
    }
}

//===

#if swift(>=3.2)
    
extension TransitionBetween
{
    // if let appPreparing = TransitionBetween<M.App.Preparing, M.App.Running>(diff)?.oldState
    // if let appRunning = TransitionBetween<M.App.Preparing, M.App.Running>(diff)?.newState
    
    public
    init?(_ diff: GlobalMutation)
    {
        guard
            let mutation = diff as? TransitionOf<From.ParentFeature>,
            let oldState = mutation.oldState as? From,
            let newState = mutation.newState as? Into
        else
        {
            return nil
        }
        
        //===
        
        self = TransitionBetween(oldState: oldState, newState: newState)
    }
}
    
#endif

// MARK: Deinitialization

extension DeinitializationOf: GlobalMutation
{
    public
    static
    var feature: Feature.Type { return F.self }
    
    //===
    
    // if let someAppState = DeinitializationOf<M.App>(diff)?.oldState
    
    public
    init?(_ diff: GlobalMutation)
    {
        guard
            let mutation = diff as? DeinitializationOf<F>
        else
        {
            return nil
        }
        
        //===
        
        self = mutation
    }
}

//===

extension DeinitializationFrom
{
    // if let appRunning = DeinitializationFrom<M.App.Running>(diff)?.oldState
    
    public
    init?(_ diff: GlobalMutation)
    {
        guard
            let mutation = diff as? DeinitializationOf<S.ParentFeature>,
            let oldState = mutation.oldState as? S
        else
        {
            return nil
        }
        
        //===
        
        self = DeinitializationFrom(oldState: oldState)
    }
}
