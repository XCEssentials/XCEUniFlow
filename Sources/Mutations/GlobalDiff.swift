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
    
    // if let newRunning = InitializationOf<M.App>(mutations).newState
    
    public
    init?(_ changes: GlobalDiff)
    {
        guard
            let mutation = changes as? InitializationOf<F>
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
    // if let newRunning = InitializationInto<M.App.Running>(mutations).newState
    
    public
    init?(_ changes: GlobalDiff)
    {
        guard
            let mutation = changes as? InitializationOf<S.ParentFeature>,
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
    
    // if let running = ActualizationOf<M.App>(mutations).state
    
    public
    init?(_ changes: GlobalDiff)
    {
        guard
            let mutation = changes as? ActualizationOf<F>
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
    // if let running = ActualizationIn<M.App.Running>(mutations).state
    
    public
    init?(_ changes: GlobalDiff)
    {
        guard
            let mutation = changes as? ActualizationOf<S.ParentFeature>,
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
    
    // if let oldRunning = TransitionOf<M.App>(mutations).oldState
    // if let newRunning = TransitionOf<M.App>(mutations).newState
    
    public
    init?(_ changes: GlobalDiff)
    {
        guard
            let mutation = changes as? TransitionOf<F>
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
    // if let oldRunning = TransitionFrom<M.App.Running>(mutations).oldState
    
    public
    init?(_ changes: GlobalDiff)
    {
        guard
            let mutation = changes as? TransitionOf<S.ParentFeature>,
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
    // if let newRunning = TransitionInto<M.App.Running>(mutations).newState
    
    public
    init?(_ changes: GlobalDiff)
    {
        guard
            let mutation = changes as? TransitionOf<S.ParentFeature>,
            let newState = mutation.newState as? S
        else
        {
            return nil
        }
        
        //===
        
        self = TransitionInto(newState: newState)
    }
}

// MARK: FeatureMutation variants - Deinitialization

extension DeinitializationOf: FeatureMutation
{
    public
    static
    var feature: Feature.Type { return F.self }
    
    //===
    
    // if let oldRunning = DeinitializationOf<M.App>(mutations).oldState
    
    public
    init?(_ changes: GlobalDiff)
    {
        guard
            let mutation = changes as? DeinitializationOf<F>
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
    // if let oldRunning = DeinitializationFrom<M.App.Running>(mutations).oldState
    
    public
    init?(_ changes: GlobalDiff)
    {
        guard
            let mutation = changes as? DeinitializationOf<S.ParentFeature>,
            let oldState = mutation.oldState as? S
        else
        {
            return nil
        }
        
        //===
        
        self = DeinitializationFrom(oldState: oldState)
    }
}
