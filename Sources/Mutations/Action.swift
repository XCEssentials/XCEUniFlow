public
struct Action
{
    let name: String
    let context: Any.Type
    let body: ActionBody
    
    //===
    
    public
    var contextDescription: String { return String(reflecting: context) }
    
    public
    var fullName: String { return "\(self.name)/\(self.contextDescription)" }
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
