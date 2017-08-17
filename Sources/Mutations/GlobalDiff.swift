public
protocol GlobalDiff { }

//===

public
struct NoMutation: GlobalDiff { } // like initial update

//===

public
struct UnspecifiedMutation: GlobalDiff { } // maybe multiple mutations???

//===

public
protocol FeatureMutation: GlobalDiff
{
    static
    var feature: Feature.Type { get }
}

// MARK: FeatureMutation variants - Initialization

extension InitializationOf: FeatureMutation
{
    public
    static
    var feature: Feature.Type { return F.self }
    
    //===
    
    // if let newRunning = InitializationOf<M.App>(diff).newState
    
    public
    init?(_ diff: GlobalDiff)
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
    // if let newRunning = InitializationInto<M.App.Running>(diff).newState
    
    public
    init?(_ diff: GlobalDiff)
    {
        guard
            let mutation = diff as? InitializationOf<S.ParentFeature>,
            let newState = mutation.newState as? S
        else
        {
            return nil
        }
        
        //===
        
        self = InitializationInto(newState: newState)
    }
}

// MARK: FeatureMutation variants - Actualization

extension ActualizationOf: FeatureMutation
{
    public
    static
    var feature: Feature.Type { return F.self }
    
    //===
    
    // if let running = ActualizationOf<M.App>(diff).state
    
    public
    init?(_ diff: GlobalDiff)
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
    // if let running = ActualizationIn<M.App.Running>(diff).state
    
    public
    init?(_ diff: GlobalDiff)
    {
        guard
            let mutation = diff as? ActualizationOf<S.ParentFeature>,
            let state = mutation.state as? S
        else
        {
            return nil
        }
        
        //===
        
        self = ActualizationIn(state: state)
    }
}

// MARK: FeatureMutation variants - Transition

extension TransitionOf: FeatureMutation
{
    public
    static
    var feature: Feature.Type { return F.self }
    
    //===
    
    // if let oldRunning = TransitionOf<M.App>(diff).oldState
    // if let newRunning = TransitionOf<M.App>(diff).newState
    
    public
    init?(_ diff: GlobalDiff)
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
    // if let oldRunning = TransitionFrom<M.App.Running>(diff).oldState
    
    public
    init?(_ diff: GlobalDiff)
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
    // if let newRunning = TransitionInto<M.App.Running>(diff).newState
    
    public
    init?(_ diff: GlobalDiff)
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
    // if let oldPreparing = TransitionBetween<M.App.Preparing, M.App.Running>(diff).oldState
    // if let newRunning = TransitionBetween<M.App.Preparing, M.App.Running>(diff).newState
    
    public
    init?(_ diff: GlobalDiff)
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

// MARK: FeatureMutation variants - Deinitialization

extension DeinitializationOf: FeatureMutation
{
    public
    static
    var feature: Feature.Type { return F.self }
    
    //===
    
    // if let oldRunning = DeinitializationOf<M.App>(diff).oldState
    
    public
    init?(_ diff: GlobalDiff)
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
    // if let oldRunning = DeinitializationFrom<M.App.Running>(diff).oldState
    
    public
    init?(_ diff: GlobalDiff)
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
