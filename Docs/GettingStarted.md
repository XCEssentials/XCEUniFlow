## Table of contents

- [Concept](#concept)
- [Dispatcher](#dispatcher)
- [Feature](#feature)
- [Action](#action)
  * [.via() and .automatically()](#via-and-automatically)
- [Bindings](#bindings)
  * [ModelBinding](#modelbinding)
  * [ObserverBinding](#observerbinding)
  * [.when()](#when)
      - [Basic mutations](#basic-mutations)
      - [Aggregated helpers](#aggregated-helpers)
  * [.givn()](#givn)
    + [.when().givn()](#whengivn)
    + [.givn().givn()](#givngivn)
  * [.then()](#then)







## Concept

```
                               Dispatcher [
Initialize                        GlobalModel [
Change State       dispatch        Feature1(Feature1.State2),     send
Actualize State    ------->        Feature2(Feature2.State4),  ------------> [Subscribers]
Deinitialize        action         ...                         notifications
                                 ]
                               ]
```

The idea behind UniFlow is pretty easy. Its approach helps to keep state in one place and change it in very specific workflow.

`Dispatcher` holds a read-only (from outside) `GlobalModel` with `Features` in their `States`.
The only way to change state of a `Feature` - is to dispatch an `Action` with a necessary `Mutation`.
After this `Dispatcher` updates the `Feature` in the `GlobalModel` by applying the `Mutation` and sends notifications about it to all objects, subscribed for updates.

Any object can send `Action` in order to init, update or deinit `Feature`.
Any object can subscribe for all kinds of state updates and react to that as needed.

---

## Dispatcher

```swift
class Dispatcher {
  var internal(set)
  state = GlobalModel()

  var bindings: [ModelBinding.GroupId: [ModelBinding]]
  var subscriptions: [Subscription.Identifier: Subscription]

  var proxy = Proxy(for: self)

  class Proxy {
    func submit(_ action: Action)
  }
}
```

`Dispatcher` holds:
- `GlobalModel` with different `Feature`
- `ModelBinding`
- `Subscription`

For usage just create dispatcher and inject it's proxy:
`Dispatcher(defaultReporting: reportingLevel).proxy.submit(someAction)`

`Dispatcher` instance is being used for adding, updating and deleting features. For this we need to submit corresponding actions.

After any changes to `GlobalModel` `Dispatcher` sends notifications to all subscriptions and bindings.



---



## Feature

```swift
protocol Feature {
  var name: String

  // Use protocol `NoBindings` to avoid defining bindings.
  var bindings: [ModelBinding]
}
```

Specific `Feature` implementation contains:

   1) All possible states (usually `struct`s), conforming to next protocols:
   `StateAuto` - for basic states without parameters, getting created by the framework after calling `.automatically()`.
   `State` - for states with extra fields, which must be created manually.


```swift
enum FileDownloading: Feature
{
    struct Starting: StateAuto
    {
        typealias Parent = FileDownloading
    }

    struct InProgress: UFLState
    {
        typealias Parent = FileDownloading

        let progress: Double
    }

    struct Completed: StateAuto
    {
        typealias Parent = FileDownloading
    }
}
```

And that's how we can do initialization to this states:

```swift
// 1) Basic state

initialize
.Into<Starting>
.automatically()


// 2) State with parameters

initialize
.Into<InProgress>
.via { setStateToDispatcherClosure, _ in
  let inProgressState = InProgress(progress: 10.0)
  setFeatureStateInGlobalModel(inProgressState)
}
```


2) Factory methods to create any actions, which will affect `Feature` state in some way. `Action` produces `Mutation`, which will be used by `Dispatcher` to update `GlobalModel`.

Example
```swift
enum FileDownloading: Feature
{
  struct Starting: StateAuto {}

  static func initializeToStartingStateAction() -> Action {
      return initialize
             .Into<Starting>
             .automatically()
  }
}


// Now let's use it

let action = FileDownloading.initializeToStartingStateAction()
dispatcher.submit(action)
```


---



## Action

`Action` is an object, which produces `Mutation`, used by `Dispatcher` to change it's `GlobalModel`
`Action`, in a way, is just a wrapper for different kinds of mutations.

```swift
Action(
  scope: String,
  context: String,
  kind: Type,
  body: (GlobalModel, SubmitAction) -> Mutation
)

Example
let action = Action(
  scope: #file,
  context: #function,
  kind: TransitonBetween<FileDownloading.InProgress, FileDownloading.Completed>,
  body: { globalModel, submit in
    let oldState =
    let newState = Into()
    return Transition(from: oldState, into: newState)
  }
)
```
`kind: Type` - mutation type.
`SubmitAction` - closure, which allows to submit created `Action` to `Dispatcher`.

There is a set of static helpers for creating actions with all kinds of mutations inside a `Feature`.

> **Hint**
> Precondition - it's a check, which will be performed before applying a `Mutation`.
> If it's not satisfied - `Action` with this `Mutation` will be rejected.



**List of all helpers**


```swift
enum FileDownloading: Feature
{
  struct Starting: StateAuto {}
  struct InProgress: StateAuto {let double}
  struct Completed: StateAuto {}

  static func createSomeAction() -> Action {
      let action =
```


Initialize FileDownloading `Feature` in a `GlobalModel`.
Precondition: `Feature` doesn't exist in the model yet.

```swift
    1) initialize.Into<Starting>.automatically()
    2) initialize.Into<InProgress>.via { // Create InProgress state with the parameter }
```


Update current state of the `Feature` with new parameters values.  
Precondition: `Feature` is in **In** state.

```swift
    3) actualize.In<InProgress>.via { // Create InProgress state with new parameter value }
```



Change `Feature` state from one to another. 
Precondition: `Feature` is in **From** state.

```swift
    4) transition.Between<Starting, Completed>.automatically()
    5) transition.Between<Starting, InProgress>.via { // Create InProgress state with the parameter }
```



Change `Feature` state from **any** to new  
Precondition: `Feature` is initialized  
Precondition: (same: .yes/.no) - defines if it's allowed to set the same state again
```swift
    6) transition.Into<Completed>.automatically(same: .yes/.no)
    7) transition.Into<InProgress>.via(same: .yes/.no) { // Create InProgress state with the parameter }
```



Remove feature from `GlobalModel`
Precondition: `Feature` is initialized
Precondition: `Feature` is in **From** state, if it's indicated

```swift
		8) deinitialize.automatically()
		9) deinitialize.From<Completed>.automatically()
```


Execute via() closure without changing state if precondition is fulfilled

```swift
		10) trigger.Uninitialized.via {} // Precondition: Feature doesn't exist in GlobalModel
		11) trigger.Initialized.via {} // Precondition: Feature is in any state
		12) trigger.In<Starting>.via {} // Precondition: Feature is in a provided State

    return action
  }
}
```



### .via() and .automatically()

All the helpers in the list above have either `via()` or `automatically()` calls at the end.
This needs some clarification.

`.automatically()` is used in situations, when mutation can be created without any manual initialization,
 while `.via()` - when it's not possible or when we want to have custom implementation.
Let's looks at the examples from the code above.

```swift
enum FileDownloading: Feature
{
  struct Starting: StateAuto {}
  struct InProgress: StateAuto {let progress: double}

  ...

  // In this case state types do not have any parameters
  // and can be created automatically

  - transition.Between<Starting, Completed>.automatically()



  // But in this one type InProgress has 'progress' field
  // and the framework doesn't know how to initialize it.
  // That's why we have to do it manually.
  ]
  - transition.Between<Starting, InProgress>.via {
      // Create InProgress state with the parameter
    }
}
```

`.automatically()` call also can take a closure parameter like `.via()`, but it's optional.<br/>
This makes sense - for `.automatically()` `Action` will be created automatically in any case, and closure (if specified) will be executed just before that. While for `.via()` a closure is required, because there is not other way to create a `Mutation`.

Here is the example of syntax for both of them:

```swift
enum FileDownloading: Feature
{
  struct Starting: StateAuto {}
  struct InProgress: StateAuto {let progress: double}

  ...


    // In this case we can submit some new Action 
    // with the provided closure 'submitAction()'.
    // But state transition for this Feature will happen automatically.

    let action  = transition.Between<Starting, Completed>.automatically() {
                    submitAction in
                      print("File completed downloading")
                      let updateCompletedFilesCountAction = SomeAction()
                      submitAction(updateCompletedFilesCountAction)
                }


    // In this case we have create and set new State manually.
  	// Together with that we can perform same actions
	  // as in the example above.
  	// In this closure we have all important parameters:
  	// globalModel, fromState - data to work with
  	// becomeInto - closure to set new State
	  // submitAction - closure to submit new Action

    let action  = transition.Between<Starting, InProgress>.via() {
                    globalModel, fromState, becomeInto, submitAction in
                      let newState = InProgress(progress: 33.0)
                      becomeInto(newState)
      
      								print("File completed downloading")
                      let updateCompletedFilesCountAction = SomeAction()
                      submitAction(updateCompletedFilesCountAction)
                }
}
```

---



## Bindings

`Binding` is the way to receive updates any about changes in `GlobalModel`.
There are two slightly different binding types - `ModelBinding` for using in `Feature` subclass and `ObserverBinding` - for any other object. The difference will be explained later.



### ModelBinding

`Binding` is intended as a behaviour descriptor, so it should be defined on a type level. It can be achieved by making a static array of `Binding` objects for a type.
For `Feature` it's required to be like this:


```swift
public protocol Feature
{
    ...
    static var bindings: [ModelBinding] { get }
}
```


`Binding` is defined in 3 simple steps:
1. when() - for which `Mutation` do we want to listen
2. givn() - how do we process received data (`Mutation`, `GlobalModel` etc). As far as sometimes we either don't need to process data or need to do multiple operations - givn() can be dropped or used multiple times in a row.
3. then() - what do we want to do



**Example**
```swift
enum FileDownloading: Feature
{
  struct Starting
  struct InProgress: StateAuto {
    let progress: Double
  }
  struct Completed

  static var bindings: [ModelBinding] {
    scenario()
            .when("FileDownloading feature updated it's progress",
                  ActualizationIn<FileDownloading.InProgress>.done)
            .givn("Progress of the downloading",
                  mapMutation: { mutation in
                    let newState: InProgress = mutation.newState
                    return newState.progress
                  })
            .then("Print the progress",
                  do: { submitAction, givenOutput in
                      print("Progress: \(givenOutput)%")
                  })
  }
}
```

In this example we create the binding inside the feature itself to perform some specific actions when the feature is getting updated. It reads like this:
1. When FileDownloading is in InProgress state and it was actualized.
2. Take the mutation and get new progress value from it.
3. Then print the progress value, received from the previous step.



### ObserverBinding

Subscription is a way to create `ObserverBinding` for any other object besides `Feature`.

There are 3 steps required to achieve this:

```swift
// 1) Inherit UFLStateObserver

class DownloadingViewModel: UFLStateObserver
{

  // 2) Implement protocol UFLStateObserver by adding static array 
  // of bindings to the target type (just like we do it for Feature)

	static var bindings: [ObserverBinding] {
    scenario()
            .when("FileDownloading feature updated it's progress",
                  ActualizationIn<FileDownloading.InProgress>.done)
           ...
  }


	// 3) Subscribe for the notifications
  
	func subscribeForNotifications(from: dispatcher) {
		dispatcher.subscribe(self)
	}
}
```




### .when()

Interface is pretty basic here:
```swift
when(_ specification: String, _: T.Type)


scenario().when("FileDownloading feature updated it's progress", 		 
                ActualizationIn<FileDownloading.InProgress>.done)
					.then( ...
```
Where T:Type is a `Mutation` type we are listening for.



> **Hint**
>
>  `.done` is just an alias for `.Type`.



Here is the list of all available options for **when** condition.
They include all previously described mutations + few new aggregated helpers.

##### Basic mutations

- `InitializationInto<Feature.State>`
- `ActualizationIn<Feature.State>`
- `TransitionInto<Feature.State>`
- `TransitionFrom<Feature.State>`
- `TransitionBetween<Feature.OldState, Feature.NewState>`
- `Deinitialization<Feature>`
- `DeinitializationFrom<Feature.State>`



##### Aggregated helpers

 Can be used to subscribe for different combinations of mutations:

- `AnyMutation`  _Mutation of any Feature_
- `AnyMutationOf<Feature>` _Mutation of a specified Feature_
- `AnyUpdateOf<Feature>` _Actualization + Mutation of a specified feature_
- `AnySettingOf<Feature>` _Initialization + Actualization + Mutation of a specified feature_
- `SettingInto<Feature.State>` _Mutation that sets the specified Feature in the specified State_




### .givn()

`.givn()` calls can be ommited or chained one after another multiple times if needed.
They can be used for mapping or validating a data.
There is a small difference between chaining `when().givn()` and  `givn().givn()`.
`GlobalModel` parameter is a copy of the latest state.
`WhenOutput` is a mutation object of type, specified in the preceding `.when()` call.



#### .when().givn()

Methods below are available for `when().givn()` chaining.

`map*` methods can be used for mapping data and sending new value to the next call in chain.

- `.givn(spec, mapState(GlobalModel))`
- `.givn(spec, mapMutation(WhenOutput))`
- `.givn(spec, map(GlobalModel, WhenOutput))`



`with*` methods don't return anything and can be used for performing checks and throwing an error to break the chain.

- `.givn(spec, withState(GlobalModel))`
- `.givn(spec, withMutation(WhenOutput))`
- `.givn(spec, with(GlobalModel, WhenOutput))`



`if*` methods are used for validation. They must return bool value and if it's false - error will be thrown automatically.

- `.givn(spec, ifMapState(GlobalModel))`
- `.givn(spec, ifMapMutation(WhenOutput))`
- `.givn(spec, ifMap(GlobalModel, WhenOutput))`



#### .givn().givn()

Methods below are available for both `givn().givn()` chaining.
Their behaviour is exactly the same as for methods before, with only one difference - instead of `Mutation`(which called `WhenOutput`) they receive mapped value from a previous .`givn`() (which called `GivenOutput`).

- `.givn(spec, mapState(GlobalModel))`
- `.givn(spec, mapInput(GivenOutput))`
- `.givn(spec, map(GlobalModel, GivenOutput))`



- `.givn(spec, withState(GlobalModel))`
- `.givn(spec, withMutation(GivenOutput))`
- `.givn(spec, with(GlobalModel, GivenOutput))`



- `.givn(spec, ifMapState(GlobalModel))`
- `.givn(spec, ifMapMutation(GivenOutput))`
- `.givn(spec, ifMap(GlobalModel, GivenOutput))`



### .then()
It is a final call in a chain, which creates a `Binding` if there were no errors thrown before.
It can be used for defining a behaviour - like executing some code or firing new `Action` or few of them.
There are few different shortcuts which make this easier.

`do()` closures don't return anything and provide a `submit(Action)` function as a parameter to submit an `Action` to `Dispatcher` manually from inside the closure.
 - `.then(spec, do(SubmitAction))`
 - `.then(spec, do(SubmitAction, GivenOutput))`

```swift
// Example

.then("Mark downloading completed", do { submitAction in
    let action = transition.Between<InProgress, Completed>.automatically()
    submitAction(action)
})
```



`submit()` closures must produce `Action`, which will be automatically submitted to `Dispatcher`.
 - `.then(spec, submit() -> Action)`
 - `.then(spec, submit(GivenOutput) -> Action)`

```swift
// Example

.then("Mark downloading completed", submit {
   let action = transition.Between<InProgress, Completed>.automatically()
   return action
})
```



These shortcuts just take one or multiple `Action`, which will be automatically submitted to `Dispatcher`.

 - `.then(spec, submit: Action)`
 - `.then(spec, submit: [Action])`

```swift
// Example

let action = transition.Between<InProgress, Completed>.automatically()
...
.then("Mark downloading completed", submit: action)
```
