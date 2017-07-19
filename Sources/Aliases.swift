public
typealias Mutations<Value> = (_: inout Value) -> Void

public
typealias ModelMutations = (_: inout GlobalModel) -> Void

public
typealias ModelMutationsWrapped = (ModelMutations) -> Void

public
typealias ActionGetter = () -> Action

public
typealias ActionGetterWrapped = (ActionGetter) -> Void

public
typealias ActionBody = (
    GlobalModel,
    ModelMutationsWrapped,
    @escaping ActionGetterWrapped
    ) throws -> Void

public
typealias DispatcherProxy = (
    //  https://en.wikipedia.org/wiki/Proxy_pattern
    subscribe: (AnyObject) -> SubscriptionBlank,
    subscribeLater: (AnyObject) -> SubscriptionBlank,
    unsubscribe: (AnyObject) -> Void,
    submit: ActionGetterWrapped
    )

//=== MARK: Prefixed versions

public
typealias UFLMutations<Value> = Mutations<Value>

public
typealias UFLModelMutations = ModelMutations

public
typealias UFLModelMutationsWrapped = ModelMutationsWrapped

public
typealias UFLActionGetter = ActionGetter

public
typealias UFLActionGetterWrapped = ActionGetterWrapped

public
typealias UFLActionBody = ActionBody

public
typealias UFLAction = Action

public
typealias UFLActionContext = ActionContext

public
typealias UFLFeature = Feature

public
typealias UFLFeatureState = FeatureState

public
typealias UFLSimpleState = SimpleState

//public
//typealias UFL = <#type expression#>

public
typealias UFLDispatcher = Dispatcher

public
typealias UFLDispatcherProxy = DispatcherProxy
