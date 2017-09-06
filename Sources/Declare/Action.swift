public
struct Action
{
    public
    let scope: String
    
    public
    let context: String
    
    public
    let type: Any.Type
    
    //===
    
    let body: ActionBody
    
    //===
    
    // unavailable directly from outside of the module
    init(
        _ scope: String,
        _ context: String,
        _ type: Any.Type,
        _ body: @escaping ActionBody
        )
    {
        self.scope = scope
        self.context = context
        self.type = type
        self.body = body
    }
    
    //===
    
    public
    var name: String { return "\(context)@\(scope)" }
    
    public
    var typeDescription: String { return String(reflecting: type) }
    
    public
    var description: String { return "\(typeDescription) // \(name)" }
}

// MARK: Helper types

typealias ActionBody =
    (GlobalModel, @escaping SubmitAction) throws -> GlobalMutationExt?

public
typealias SubmitAction = (Action) -> Void

//===

public
typealias SubmitMutations = ([GlobalMutation]) -> Void

//===

public
typealias Become<S: FeatureState> = (S) -> Void

//===

public
typealias Mutate<S: FeatureState> = (inout S) -> Void

//===

//public
//typealias Wrapped<Value> = (Value) -> Void
//
//public
//typealias ActionGetter = () -> Action
//
//public
//typealias Mutations<Value> = (_: inout Value) -> Void

//===

public
typealias StateGetter<State: FeatureState> = () -> State

// MARK: Operators - Submit action to proxy

public
func << (proxy: Dispatcher.Proxy, action: Action)
{
    proxy.submit(action)
}

public
func << (proxy: Dispatcher.Proxy, actionGetter: () -> Action)
{
    proxy.submit(actionGetter())
}

// MARK: Operators - Pass action to 'submit' handler

public
func << (submit: SubmitAction, action: Action)
{
    submit(action)
}

public
func << (submit: SubmitAction, actionGetter: () -> Action)
{
    submit(actionGetter())
}

// MARK: Operators - Pass feature state to 'become' handler

public
func << <S: FeatureState>(become: Become<S>, state: S)
{
    become(state)
}
