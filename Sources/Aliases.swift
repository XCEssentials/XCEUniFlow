// MARK: Prefixed global aliases

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

public
typealias UFLDispatcherNotification = MutationsAnnotation

public
typealias UFLInitialUpdate = NoMutations

public
typealias UFLUnspecifiedMutation = UnspecifiedMutation

public
typealias UFLFeatureMutation = FeatureMutation

public
typealias UFLInitializationOf<F: Feature> = InitializationOf<F>

public
typealias UFLActualizationOf<F: Feature> = ActualizationOf<F>

public
typealias UFLTransitionOf<F: Feature> = TransitionOf<F>

public
typealias UFLDeinitializationOf<F: Feature> = DeinitializationOf<F>
