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
        body: @escaping ActionBody
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

public
typealias ActionBody = (
    _ model: GlobalModel,
    _ submit: @escaping Wrapped<ActionGetter>
    )
    throws -> (Mutations<GlobalModel>, MutationsAnnotation)?

public
typealias Wrapped<Value> = (Value) -> Void

public
typealias ActionGetter = () -> Action

public
typealias Mutations<Value> = (_: inout Value) -> Void

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
func << (submit: Wrapped<ActionGetter>, action: Action)
{
    submit { action }
}

public
func << (submit: Wrapped<ActionGetter>, actionGetter: () -> Action)
{
    let action = actionGetter()
    submit { action }
}

// MARK: Operators - Pass feature state to 'become' handler

public
func << <S: FeatureState>(become: Wrapped<StateGetter<S>>, state: S)
{
    become { state }
}
