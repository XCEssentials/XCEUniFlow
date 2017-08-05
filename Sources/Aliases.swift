public
typealias Wrapped<Value> = (Value) -> Void

public
typealias Mutations<Value> = (_: inout Value) -> Void

public
typealias StateGetter<State: FeatureState> = () -> State

public
typealias ActionGetter = () -> Action

public
typealias ActionBody = (
    _ model: GlobalModel,
    _ submit: @escaping Wrapped<ActionGetter>
    ) throws -> (Mutations<GlobalModel>, MutationAnnotation.Type)?

//=== MARK: Prefixed versions

public
typealias UFLWrapped<Value> = Wrapped<Value>

public
typealias UFLMutations<Value> = Mutations<Value>

public
typealias UFLStateGetter<State: FeatureState> = StateGetter<State>

public
typealias UFLActionGetter = ActionGetter

public
typealias UFLActionBody = ActionBody

public
typealias UFLAction = Action

public
typealias UFLFeature = Feature

public
typealias UFLFeatureState = FeatureState

public
typealias UFLSimpleState = SimpleState

public
typealias UFLDispatcher = Dispatcher

public
typealias UFLGlobalModel = GlobalModel
