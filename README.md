[![license](https://img.shields.io/github/license/XCEssentials/UniFlow.svg)](https://opensource.org/licenses/MIT)
[![GitHub tag](https://img.shields.io/github/tag/XCEssentials/UniFlow.svg)](https://github.com/XCEssentials/UniFlow/releases)
[![CocoaPods](https://img.shields.io/cocoapods/v/XCEUniFlow.svg)](https://cocoapods.org/?q=XCEUniFlow)
[![CocoaPods](https://img.shields.io/cocoapods/p/XCEUniFlow.svg)](https://cocoapods.org/?q=XCEUniFlow)

# Problem

Every app has an architecture, good or bad. Since there is no universal methodology about how to build an app, every developer/team has to come up with their own solution every time an app is being built.

There are several fundamental challenges that every app has to solve, it doesn't matter what this app is about:

- data model sharing (data exchange and synchronization between different scopes/views/modules/etc.);
- maintaining data consistency at any given moment of time across whole app;
- managing app states;
- multithreading synchronization.

Optionally, there are few more fundamental challenges that every app faces sooner or later (not everyone makes it a priority, but it becomes more-or-less necessary at some point of time during evolution of the project):

- maintain (at least some) code structure, so (at least some) rules on code organization become necessary, especially if two or more developers work on the app at the same time;
- separate [business logic](https://en.wikipedia.org/wiki/Business_logic) layer from [presentation logic](https://en.wikipedia.org/wiki/Presentation_logic) layer;
- eliminate (at least) critical issues at run time that lead to crashes (horrible experience for end users, very harmful for any app considering how competitive mobile app market is now);
- eliminate bugs caused by unexpected behavior (that kind of behavior often leads to crashes in run time as well);
- keep source code documented.

So let's define **app architecture** as a set of rules that define how listed above challenges are being solved in particular app.

# Pre-existing solutions

There are quite few design patterns that are trying to describe how to organize overall application structure on a high level ([MVC](https://en.wikipedia.org/wiki/Model%E2%80%93view%E2%80%93controller), [MVVM](https://en.wikipedia.org/wiki/Model%E2%80%93view%E2%80%93viewmodel), etc.). They are not very specific and different developers interpret and implement these patterns in a slightly different way.

One of the most promising (and relatively new on iOS) is so-called **"unidirectional data flow"** pattern introduced by [Facebook](https://www.facebook.com) in their [Flux](https://github.com/facebook/flux) framework. The most well established native implementation of this pattern for Apple platforms written in Swift is [ReSwift](https://github.com/ReSwift/ReSwift).

It's a very powerful framework that seems to cover all the fundamental needs. However, there are several things that are not so great and might be improved.

## Overhead with Reducer implementation

1. **Reducer** is not supposed to have any internal state/data ever, so the only value of **reducer** is the logic that can be easily represented as a pure function (with input parameters), so it doesn't make sense to have **reducer** as an object/instance and implement it's functionality as instance member/function.
2. The way **reducers** are supposed to be implemented adds unnecessary "manual" work to developer and very likely will lead to errors/mistakes as the codebase grows. In particular, developer has to implement every **reducer** as an object/struct and then always remember (during application and **store** initialization) to create exactly one instance of each **reducer** and explicitly register it in the **store**. Otherwise, **reducer** will not be included in the **actions** processing chain and silently will not work.
3. Entire library architecture promotes very strange and inconvenient way of organizing app logic/code. Each **action** supposed to represent only data model needed for the logic related to this **action**, while logic itself is spread across one or multiple **reducers**. The only way to recall/understand what a particular **action** does, without having detailed up-to-date documentation, is to search across whole app for **reducers** which react to that specific **action**. That's a nightmare for developer, leads to lack of understanding of big picture by developer and, as result - to errors/bugs/crashes in the app and pure overall app UX.
4. The way **reducer** main function expected to be written is far from perfect. While it may look cool because it's pure "functional" approach, it's lot of manual work for developer that implements app functionality. We have to do check/unwrap optional **state** in every single reducer, before we even start to write any app-specific code, which is just ridiculous - why wouldn't we have the 'state' set at any moment of application life time? Plus, it comes as read-only input parameter and you HAVE to return a state value, even if this action made no mutations on state at all - that all makes developer (in most cases) to explicitly unwrap optional input state into a variable ("var"). We also do not know what the **action** is and have to always optionally typecast it or at least check its type. That's lot of unnecessary complications that make the logic behind the source code hard to read and understand, so, again, it's very error-prone.

## Subscription mechanism limitations

The subscription mechanism requires:

1. **observer** to have a specific method implemented (conform to protocol) that limits developer with naming;
2. this specific method (**newState**) receives optional value, that require the code to always have unwrapping code before any app-specific code comes, which is on a big scale a big unnecessary manual work to be done by developer.

## Middleware

**Middleware** seems to be absolutely overkill/unnecessary complication, even a simple example looks super complicated.

# Wishlist

A framework like this should be a tool that helps and inspires to:

1. make the app completely predictable at any moment of time (so that eliminates crashes);
2. effectively exchange/share data between different scopes (without having to store and maintain direct cross-references in many-to-many style) so all parts of the app (including all UIs) stay consistent all the time;
3. eliminate implicit [side effects](https://en.wikipedia.org/wiki/Side_effect_(computer_science)) in application source code;
4. make the app source code well structured - easy to read, understand and reason about;
5. make the app source code compatible with key software design principle (like [Separation of concerns](https://en.wikipedia.org/wiki/Separation_of_concerns), [Encapsulation](https://en.wikipedia.org/wiki/Information_hiding#Encapsulation), [Black box](https://en.wikipedia.org/wiki/Black_box), [Dependency Injection](https://en.wikipedia.org/wiki/Dependency_injection));
6. make the app source code compatible with key architectural patterns (like [MVVM](https://en.wikipedia.org/wiki/Model%E2%80%93view%E2%80%93viewmodel), [MVC](https://en.wikipedia.org/wiki/Model%E2%80%93view%E2%80%93controller)).
7. make the app source code easily translatable to/from [BDD](https://en.wikipedia.org/wiki/Behavior-driven_development) specifications;
8. make application source code ready for unit tests (including independent module testing and integration testing);
9. keep developer written source code minimal and compact (make it look like specifications);
10. keep library overhead as low as possible (no run-time "magic" should be involved, as less "manual" operations as possible).

# Scope

This library provides the highest level of abstraction in application development process, so any kind of specific tasks (like networking, data encoding/decoding, any kind of computations, GUI configuration, etc.) are out of scope.

# Theoretical fundamentals

Any **app consists of** two main components: **[model](https://en.wikipedia.org/wiki/Data_model)** (static component, which provides storage for all possible kinds of [data](https://en.wikipedia.org/wiki/Data) that the app can operate with) and **[business logic](https://en.wikipedia.org/wiki/Business_logic)** (dynamic component, which represents all possible mutations that might happen with that data model).

On the other hand, computer program (app) is a [State Machine](https://en.wikipedia.org/wiki/Finite-state_machine). This, in particular, means, that **to write an app** we have to **define** all possible app **states** and all possible **transitions** between these states which we wish to allow.

Moreover, each app consists of features, which may or may not depend one on another. Every feature may require to store some data to operate with, to represent internal state, to deliver some computation results, etc. The exact set of required kinds of data, as well as data values may change over time.

To sum it up, every app should be represented as a set of features. Every feature can be defined by one or several *alternative* states (every feature state corresponds to its own model), plus transitions between these states. 

# Methodology overview

App model - **global model** - is a composite object that consists of feature models. To be completely precise, every feature (when presented in global model at all) at any given moment of time is represented by exactly one of its state models. Obviously, each feature state model that is currently presented in global model defines what's current state of corresponding feature; if no single state model of a given feature is presented in global model, then current state of that particular feature is undefined (the feature is not being used currently).

By app **global state** at any given moment of time lets agree to understand a combination of all feature state models currently presented in app global model.

This concludes static/data model of an app.

App business logic can be represented by transitions between different app global states. That means each transition should change current state of one or several features. In general case, each transition consists of pre-conditions which must be fulfilled before this transition can be performed, as well as transition body that defines how exactly this transition is going to be made. Transitions are also used to bring any kind of input from outer world into the app (for example, user input, system notifications, etc.)

# How to install

The recommended way is to install using [CocoaPods](https://cocoapods.org/?q=XCEUniFlow).

# How it works

Each app [feature](https://en.wikipedia.org/wiki/Software_feature) should be represented by a data type that conforms to **`Feature`** protocol. Its name corresponds to the feature name. This data type is never supposed to be instantiated and will be needed as meta data for corresponding feature states only.

Each of the app feature states should be represented by a data type that conforms to **`FeatureState`** protocol and explicitly defines corresponding feature via typealias `UFLFeature`. Instances of these data types will be used to represent their features.

All app features are supposed to be stored in a single global storage represented by data type called **`GlobalModel`**. Each app supposed to have the only intance of that type. It is a single point of truth at any moment of time, which stores global app state. On a high level, it works much like a dictionary, where app features are used as keys, and corresponding feature states are stored as values. This means that `GlobalModel` may or may not contain any given feature at any given moment of time, but if it contains a feature - it only contains one and only one particular feature state; as soon as we decide to to put another feature state into `GlobalModel` (after we made a transition) - it will override any previously saved feature state (for this particular feature) that was stored in `GlobalModel` at the moment.

Each transition should be represented by an instance of **`Action`**, a special data type (`struct`) that contains transition name and body (in the form of `closure`).

There is a special technique for how to define transition. `Action` initializer is inaccessible directly. It is supposed that all transitions should be defined in form of static functions that return `Action` instance. Such functions must be encapsulated into special data type that conforms to `ActionContext` protocol: this protocol provides exclusive access to a special static function that allows to create `Action` instance by passing into it transition body. Such technique enforces source code unification and provides great flexibility: the encapsulating function can accept any number of input parameters, that can be captured into transition body closure, but in the end transition body is always just a closure with no input parameters.

In most cases, it is recommended to encapsulate state transitions into related features, so `Feature` protocol inherits `ActionContext` protocol.

After we have defined app features, their states and transitions, we need to make it work together. Each app has to maintain one and only one dispatcher - instance of **`Dispatcher`** class. It's is recommended to create and start using one first thing after app finishes launching.

Dispatcher has several responsibilities:

- store global app state (the only instance of `GlobalModel`);
- process state transitions (instances of `Action` data type that mutate the `GlobalModel` instance stored inside dispatcher);
- deliver notifications about global state mutations to subscribed observers (this is how we can interconnect different parts/scopes of the app, including delivering updates to GUI in "reactive" style).

# How to use

Import framework like this:

```swift
import XCEUniFlow
```

## Dispatcher

First of all, you need to create a dispatcher. The recommended way is just to decalre an internal instance level constant in your `AppDelegate` class. This guarantees that dispatcher has the same life cycle as the app itself.

```swift
@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate
{
	// ...
	
	let dispatcher = Dispatcher()
	
	// ...
}
```

## DispatcherProxy

For safety reasons, it is not recommended to pass reference to dispatcher across the app. Instead, there is a special lightweight data structure called `DispatcherProxy` that provides access to essential functionality of a given dispatcher and supposed to be freely passed/copied/stored as many times as it is needed.

Access dispatcher proxy as follows:

```swift
let theProxy = dispatcher.proxy
```

For each data type that will need access to global app state, it is recommended to implement `DispatcherInitializable` or `DispatcherBindable` protocol. These two protocols implement [Dependency Injection](https://en.wikipedia.org/wiki/Dependency_injection) and unify how potential observers are being connected with dispatcher.

Here is example of custom UIWindow-subclass that implements `DispatcherInitializable` protocol.

```swift
final
class Window: UIWindow, DispatcherInitializable
{
    required
    convenience
    init(with proxy: DispatcherProxy)
    {
        self.init(frame: UIScreen.main.bounds)
        
        //===
        
        // here subscribe for updates from dispatcher via proxy, if needed
        // store proxy internally, if needed
    }
}
```

Here is example of custom UIWindow-subclass that implements `DispatcherBindable` protocol.

```swift
final
class Window: UIWindow, DispatcherBindable
{
    func bind(with proxy: DispatcherProxy) -> Window
    {
        // here subscribe for updates from dispatcher via proxy, if needed
        // store proxy internally, if needed
    }
}
```

It's responsibility of the observer to subscribe or does not subscribe for updates from dispatcher, when provided access to dispatcher proxy. Moreover, given that the observer is going to initiate global state mutations (pass into the app user input, system notifications, etc.) or may need proxy later during app execution outside of the dispatcher updates, it is also a good idea to store proxy internally for future use, because that proxy is the only recommended way to submit actions to dispatcher.

Here is example of custom UIViewController-subclass that implements `DispatcherInitializable` protocol. It does not subscribe for dispatcher notifications, but stores `proxy` for future use independent from dispatcher notifications.

```swift
// lets say we have a custom view, subclass of UIView,
// which also accepts proxy during initialization

final
class View: UIView, DispatcherInitializable
{
	// instance of this view will be created by the 'Ctrl' class defined below

	// ...
}

// ...

final
class Ctrl: UIViewController, DispatcherInitializable
{
    private(set)
    var proxy: DispatcherProxy!
    
    //===
    
    required
    convenience
    init(with proxy: DispatcherProxy)
    {
        self.init(nibName: nil, bundle: nil)
        
        //===
        
        //...
        
        self.proxy = proxy // save proxy for future use
    }
    
    // ...
    
    override
    func loadView()
    {
        // we have no guarantee when this method will be called,
        // and when it's called - we need to have the proxy available to pass it further
    
        view = View(with: proxy)
    }
}
```

## Subscription

To subscribe for notifications from dispatcher, all you need to do is, basically, register an object as observer and provide corresponding `update handler`. Optionally you may also provide `convert handler` which is responsible for converting global app state into more specific model (this helps make the code even more declarative).

In most cases, to subscribe an observer for notifications from dispatcher you need to implement one of the two mentioned earlier protocols (`DispatcherInitializable` or `DispatcherBindable`). When got access to `proxy` - just pass `self` as observer and a custom closure/function that accepts global app state as input parameter into `onUpdate` function.

Here is an example of how a custom UIView-based class subscribes for dispatcher notifications. Note, that in this example the `onUpdate` function accepts another function as input parameter - for the sake of better code organization.

```swift
final
class View: UIView, DispatcherInitializable
{
    // ...
    
    required
    convenience
    init(with proxy: DispatcherProxy)
    {
        self.init(frame: CGRect.zero)
        
        //===
        
        // ...
        
        //===
        
        proxy
            .subscribe(self)
            .onUpdate(configure)
    }
    
    // ...
    
    func configure(with model: GlobalModel)
    {
        // here use model to re-configure self as needed
    }
}
```

Optionally, you may want to pass a custom closure/function that accepts global app state and returns any kind of custom or system data type ("sub-state") into `onConvert` function, and then pass custom closure/function that accepts sub-state as input parameter into `onUpdate` function. See example below.

```swift
final
class View: UIView, DispatcherInitializable
{
    // ...
    
    required
    convenience
    init(with proxy: DispatcherProxy)
    {
        self.init(frame: CGRect.zero)
        
        //===
        
        // ...
        
        //===
        
        proxy
            .subscribe(self)
            .onConvert(prepare)
            .onUpdate(configure)
    }
    
    // ...
    
    func prepare(from globalModel: GlobalModel) -> Int?
    {
        var result: Int = nil
        
        // if possible, convert globalModel somehow into local model,
        // in this example local model represented by "Int"
        
        return result
    }    
    
    func configure(with localModel: Int)
    {
        // here use localModel to re-configure self as needed
    }
}
```

Note, that observer object works like a key in a dictionary to identify subscription among all other subscriptions. Only one subscription is possible per observer. Every submit attempt to setup a subscription for an observer will override previous subscription for this observer.

## Feature modeling

One of the most important techniques in this methodology is how to define features, feature states and state transitions.

Lets model a simple search feature.

Assume we have a simple GUI where user have a single input text field where a search keyword must be entered (it might be a single or multi-word string, it doesn't matter).

When user finishes input and starts search process, the input text field is no longer editable, the search keyword can not be changed anymore. In the background the app is doing search for the given keyword.

When the search is finished, we have on hands an array of items as result of search (might be empty), as well as the search keyword (read-only) for which these results have been found.

To define an app feature, lets declare a custom data type that conforms to `Feature` protocol. Feature data type is not supposed to be instantiated, so it's a good idea to use `enum` data type to declare app features.

```swift
enum Search: Feature
{
	// ...
}
```

Inside `Search` type, lets declare 3 nested types, they will represent corresponding `Search` states.

```swift
enum Search: Feature
{
    struct Preparing: SimpleState { typealias UFLFeature = Search
        
        // getting user input, waiting for start
    }
    
    struct InProgress: FeatureState { typealias UFLFeature = Search
        
        // the search process for a given keyword is in progress
    }
    
    struct Finished: FeatureState { typealias UFLFeature = Search
        
        // the search process for a given keyword is finished,
        // got list of results (may be empty)
    }
}
```

Note, that `SimpleState` is a special protocol inherited from `FeatureState`. All it does is gives the library a hint, that the type that conforms to that protocol can be instantiated without parameters (using default system-provided `init` constructor). That protocol is recommended for states that do not have internal variables or they have default values. We will see how it is used later.

Now lets extend each feature state with necessary constants and variables that reflects the essence of corresponding state.

In the beginning, until user finished input and started the search process, `Search` feature is supposed to be represented by `Preparing` state. We do not need to store in model anything in that state.

When user finished input and started the actual search process, and until the search process has been finished, `Search` feature supposed to be represented by `InProgress` state. While search is in progress, we may need to know what is the keyword for which we are doing search right now. So lets add a constant (!) that will store search keyword inside `InProgress` state.

```swift
struct InProgress: FeatureState { typealias UFLFeature = Search
        
    // the search process for a given keyword is in progress
    
    let keyword: String // read-only, requires to set value explicitly
}
```

When the search process has been finished, `Search` feature automatically transitions into `Finished` state. Here we still need to know what is the keyword for which we have completed search process just now, as well as represent a list of results (as we do not know what's the data type of results list elements, let it be `Any`, it doesn't matter for the purpose of this example).

```swift
struct Finished: FeatureState { typealias UFLFeature = Search
        
    // the search process for a given keyword is finished,
    // got list of results (may be empty)
    
    let keyword: String // read-only, requires to set value explicitly
    
    let results: [Any] // read-only, requires to set value explicitly
}
```

Now lets connect these states together by defining transitions.

First of all, lets define transition that initializes the feature.

```swift
extension Search
{
    static
    func setup() -> Action
    {
        return initialization(into: Preparing.self)
    }
}
```

In the example above, a special helper static function `initialization` (provided by the library) has been used. It automates many routine checks and operations. This specific helper works with one specific feature state, makes a transition where initial state is undefined and target state is as provided (`Preparing` in our case). This particular function works only with feature states that conform to `SimpleState` protocol. Under the hood it makes all the necessary checks for you - ensures that the feature is NOT presented in global state yet, and then, if everything is good, creates an instance of target state and puts it into global model, or fails action processing otherwise. More on this and other special helpers later.

submit, when user finished input and initiates search process, we need to transition from `Preparing` state into `InProgress` state. Here is an example of how it might be implemented.

```swift
static
func begin(with word: String) -> Action
{
    return transition(from: Preparing.self, into: InProgress.self) { _, become, submit in
            
            become { InProgress(keyword: word) }
            
            //===
            
            var list: [Any] = []
            
            // do the search here, on background thread most likely
            // when search is finished - return to main thread and
            // deliver results by submitting another action via 'submit' handler
            
            // ...
            
            submit { finished(with: word, results: list) }
        }
    }
```

In the example above, a special helper static function `transition` (provided by the library) has been used. It automates many routine checks and operations. This specific helper makes a transition between the two provided states of the same feature. Under the hood it makes all the necessary checks for you - ensures that the feature IS already presented in global state and its current state is as provided (`Preparing` in this case), and then, if everything is good, lets you create an instance of target state to later put it into global model for you, or fails action processing otherwise. More on this and other special helpers later.

Finally, when the search is finished, we need to transition from `InProgress` state into `Finished` state. Here is an example of how it might be implemented.

```swift
static
func finished(with word: String, results list: [Any]) -> Action
{
    return transition(from: InProgress.self, into: Finished.self) { _, become, _ in
        
        become { Finished(keyword: word, results: list) }
    }
}
```

## Execute transitions

To initiate transition processing, submit corresponding `Action` (with necessary parameters, if any) to dispatcher via its `proxy` (see example below).

```swift
let proxy = // get proxy from dispatcher
proxy.submit { Search.setup() } // initialize feature in global model
// ... wait for user input and initiation of actual search process...
let word = // get input from user
proxy.submit { Search.begin(with: word) } // actually start search process
// ...
```

Remember, all actions are being processed serially on the main thread, one-by-one, in the same order as they have been submitted (FIFO).

## Final notes

Above is an example of bare minimum that might be needed to solve a task like this. The example might be extended with a dedicated state for failure (that also may store the error occurred) on some other states, depending on specifics of particular search. Also there should be a transition that discards search results and prepares for a new search, deinitialization transition (in case the search view is closed completely and we do not need to keep in memory anything related to `Search` feature at all). And so on.

# Positive outcomes

There are quite a few positive outcomes from using this framework as a foundation for your app:

- the methodology encourages to write app source code in functional manner, that eliminates side effects, makes it better organized, easier to read and understand;
- it provides very clear strategy for scaling app from very few features to dozens and hundreds of them;
- it eliminates unexpected behavior, because if you write state transitions properly - check all necessary preconditions and secure all necessary data into temporary variables before proceed with actually making the transition - there is no chance to get an unexpected behavior or run time exception;
- it dramatically increases codebase modularity and testability (in comparison with "traditional" **imperative** programming or any other popular architecture patterns), making both module and integration testing a breeze;
- each transition (with its trigger points) is easily translatable into [BDD](https://en.wikipedia.org/wiki/Behavior-driven_development) scenario and vice versa;
- easy to deliver any data to any scope of the app, just subscribe for updates from dispatcher and read/put access desired data from/into global app state;
- the app still easily compatible with existing architecture patterns like MVC, MVVM and others, because this library only organizes Model layer.
- no need to sacrifice with performance, because this library brings no overhead at all, no run time magic, everything written in pure Swift.

# Compatibility with Objective-C

For mixed environment Swift 3 + Objective-C use [version 1.1.1](https://github.com/maximkhatskevich/MKHUniFlow/releases/tag/1.1.1). For compatibility with Swift 2.2 and Swift 2.3 (as well as Objective-C) use [older version](https://github.com/maximkhatskevich/MKHUniFlow/releases/tag/1.0).

Starting from [version 2.0.0](https://github.com/XCEssentials/UniFlow/releases/tag/2.0.0) interoperability with Objective-C is no longer supported.

# Future plans

The project has evolved through several minor and 3 major updates. Current notation considered to be stable and pretty well balanced in terms of ease of use, concise and self-expressive API and functionality. Pretty much any kind of functionality can be implemented using proposed methodology.

# Contribution, feedback, questions...

I you have any kind of feedback or questions - feel free to open an issue. If you'd like to propose an improvement or found a bug - start na issue as well, or feel free to fork and submit a pull request. Any kind of contributions would be much appreciated!
