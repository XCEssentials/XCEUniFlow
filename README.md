# UniFlow

App architecture done right, inspired by Flux (from Facebook).

## Problem

Every app has an architecture, good or bad. Since there is no universal methodology about how to build an app, every developer/team has to come up with their own solution every time an app is being built.

There are several fundamental challenges that every app has to solve, it doesn't matter what this app is about:

- data model sharing (data exchange and syncronization between different scopes/views/modules/etc.);
- maintainting data consistency at any given moment of time acros whole app;
- managing app states;
- multithreading synchronization.

Optionally, there are few more fundamental challenges that every app faces sooner or later (not everyone makes it a priority, but it becomes more-or-less necessary at some point of time during evolution of the project):

- maintain (at least some) code structure, so (at least some) rules on code organization become necessary, especially if two or more developers work on the app at the same time;
- separate [business logic](https://en.wikipedia.org/wiki/Business_logic) layer from [presentation logic](https://en.wikipedia.org/wiki/Presentation_logic) layer;
- eliminate (at least) critical issues at run time that lead to crashes (horrible experience for end users, very harmful for any app considering how competitive mobile app market is now);
- eliminate bugs casued by unexpected behavior (that kind of behavior often leads to crashes in run time as well);
- keep source code documented.

So let's define **app architecture** as a set of rules that define how listed above challenges are being solved in particular app.

## Pre-existing solutions

There are quite few design patterns that are trying to describe how to organize overall application structure on a high level ([MVC](https://en.wikipedia.org/wiki/Model%E2%80%93view%E2%80%93controller), [MVVM](https://en.wikipedia.org/wiki/Model%E2%80%93view%E2%80%93viewmodel), etc.). They are not very specific and different developers interpret and implement these patterns in a slightly different way.

One of the most promising (and relatively new on iOS) is so-called **"unidirectional data flow"** pattern introduced by Facebook in their Flux framework. The most well established native implementation of this pattern for Apple platforms written in Swift is [ReSwift](https://github.com/ReSwift/ReSwift).

It's a very powerfull framework that seems to cover all the fundamental needs. However, there are several things that are not so great and might be improved

### Overhead with Reducer implementation

1. *Reducer* is not supposed to have any internal state/data ever, so the only value of *reducer* is the logic that can be easily represented as a pure function (with input parameters), so it doesn't make sense to have *reducer* as an object/instance and implement it's functionality as instance member/function.
2. The way *reducers* are supposed to be implemented adds unnecessary "manual" work to developer and very likely will lead to errors/mistakes as the codebase grows. In particular, developer has to implement every *reducer* as an object/struct and then always remember (during application and *store* initialization) to create exactly one instance of each *reducer* and explicitly register it in the *store*. Otherwise, *reducer* will not be included in the *actions* processing chain and silently will not work.
3. Entire library architecture promotes very strange and inconvenent way of organizing app logic/code. Each *action* supposed to represet only data model needed for the logic related to this *action*, while logic itself is spread across one or multiple *reducers*. The only way to recall/understand what a particular *action* does, without having detailed up-to-date documentation, is to search across whole app for *reducsers* which react to that specific *action*. That's a nightmare for developer, leads to lack of understanding of big picture by developer and, as result - to errors/bugs/crashes in the app and pure overall app UX.
4. The way *reducer* main function expected to be written is far from perfect. While it may look cool because it's pure "functional" approach, it's lot of manual work for developer that implements app functionality. We have to do check/unwrap optional *state* in every single reducer, before we even start to write any app-specific code, which is just ridiculous - why wouldn't we have the 'state' set at any moment of application life time? Plus, it comes as read-only input parameter and you HAVE to return a state value, even if this action made no mutations on state at all - that all makes developer (in most cases) to explicitly unwrap optional input state into a variable ("var"). We also do not know what the *action* is and have to always optionally typecast it or at least check its type. That's lot of unnecessary complications that make the logic behind the source code hard to read and understand, so, again, it's very error-prone.

### Subscription mechanism limitations

The subscription mechanism requires:

1. *observer* to have a specific method implemented (conform to protocol) that limits developer with naming;
2. this specific method (*newState*) receives optional value, that require the code to always have unwrapping code before any app-specific code comes, which is on a big scale a big unnecessary manual work to be done by developer.

### Middleware

*Middleware* seems to be absolutely overkill/unnecessary complication, even a simple example looks super complicated.

## Whishlist

A framework like this should be a tool that helps and inspire to:

1. make the app completely predictable at any moment of time (so that eliminates crashes);
2. effectivly exchange/share data between different scopes (without having to store and maintain direct cross-references in many-to-many style) so all parts of the app (including all UIs) stay consistent all the time;
3. eliminate implicit [side effects](https://en.wikipedia.org/wiki/Side_effect_(computer_science)) in application source code;
4. make the app source code well structured - easy to read, understand and reason about;
5. make the app source code compatible with key software design principle (like [Separation of concerns](https://en.wikipedia.org/wiki/Separation_of_concerns), [Encapsulation](https://en.wikipedia.org/wiki/Information_hiding#Encapsulation), [Black box](https://en.wikipedia.org/wiki/Black_box), [Dependency Injection](https://en.wikipedia.org/wiki/Dependency_injection));
6. make the app source code compatible with key architectural patterns (like [MVVM](https://en.wikipedia.org/wiki/Model%E2%80%93view%E2%80%93viewmodel), [MVC](https://en.wikipedia.org/wiki/Model%E2%80%93view%E2%80%93controller)).
7. make the app source code easily translatable to/from [BDD](https://en.wikipedia.org/wiki/Behavior-driven_development) specifications;
8. make application source code ready for unit tests (including independent module testing and integration testing);
9. keep developer written source code minimal and compact (make it look like specifications);
10. keep library overhead as low as possible (no run-time "magic" should be involved, as less "manual" operations as possible).

## Methodology overview

Each computer program (**app**) is a [State Machine](https://en.wikipedia.org/wiki/Finite-state_machine). This, in particular, means, that to write an app we have to define all possible app states and all possible transitions between these states which we wish to allow.

On the other hand, each app consists of [features](https://en.wikipedia.org/wiki/Software_feature), which may or may not depend one on another. Based on this, it is fair to say that overall (global) app state at any given moment of time can be represented by a combination of one or several app features.

In its turn, each app feature can be represented by one or several alternative states. This means, that at any given moment of time a feature can be represented by one and only one of its states.

This concludes static/data model of an app.

App [business logic](https://en.wikipedia.org/wiki/Business_logic) can be represented by [state transitions](https://en.wikipedia.org/wiki/Finite-state_machine). Each of such transitions may affect one specific feature, or multiple features at once. In general case, each transition consists of pre-conditions which must be fulfilled before this trnasition can be performed, as well as transition body that defines how exactly this transition is going to be made. Transitions are also used to bring any kind of input from outer world into the app (for example, user input, system notifications, etc.)

## How to install

The recommended way of installing **UniFlow** into your project is via [CocoaPods](https://cocoapods.org). Just add to your [Podfile](https://guides.cocoapods.org/syntax/podfile.html):

```Ruby
pod 'XCEUniFlow', :git => 'https://github.com/XCEssentials/UniFlow.git'
```

## How it works

Each app [feature](https://en.wikipedia.org/wiki/Software_feature) should be represented by a data type that conforms to **`Feature`** protocol. Its name corresponds to the feature name. This data type is never supposed to be instantiated and will be needed as meta data for corresponding feature states only.

Each of the app feature states should be represented by a data type that conforms to **`FeatureState`** protocol and explicitly defines corresponding feature via typealias `UFLFeature`. Instances of these data types will be used to represent their features.

All app features are supposed to be stored in a single global storage called **`GlobalModel`**. It is a single point of truth at any moment of time, which stores global app state. On a high level, it works much like a dictionary, where app features are used as keys, and corresponding feature states are stored as values. This means that `GlobalModel` may or may not contain any given feature at any given moment of time, but if it contains a feature - it only contains one and only one particular feature state; as soon as we decide to to put another feature state into `GlobalModel` (after we made a transition) - it will override any previously saved feature state (for this particular feature) that was stored in `GlobalModel` at the moment.

Each transition should be represented by an instance of **`Action`**, a special data type (`struct`) that contains transition name and body (in the form of `closure`).

There is a special technique for how to define transition. `Action` initializer is inaccessible directly. It is supposed that all transitions should be defined in form of static functions that return `Action` instance. Such functions must be incapsuleted into special data type that conforms to `ActionContext` protocol: this protocol provides exclusive access to a sepcial static function that allows to create `Action` instance by passing into it transition body. Such technique enforces source code unification and provides great flexibility: the encapsulating function can accept any number of input parameters, that can be captured into transition body closure, but in the end transition body is always just a closure with no input parameters.

In most cases, it is recommended to incapsulate state transitions into related features, so `Feature` protocol inherits `ActionContext` protocol.

After we have defined app features, their states and transitions, we need to make it work together. Each app has to maintain one and only one dispatcher - instance of **`Dispatcher`** class. It's is recommended to create and start using one first thing afte app finishes launching.

Dispatcher has several responsibilities:

- store global app state (the only instance of `GlobalModel`);
- process state transitions (instances of `Action` data type that mutate the `GlobalModel` instance stored inside dispatcher);
- deliver notifications about global state mutations to subscribed observers (this is how we can interconnect different parts/scopes of the app, including delivering updates to GUI in "reactive" style).

## How to use

Import framework as follows:

```Swift
import XCEUniFlow
```

## Future plans

The project has evolved through several minor and 3 major updates. Current notation considered to be stable and pretty well balanced in terms of ease of use, consise and self-expressive API and functionality. Pretty much any kind of functionality can be implemented using proposed methodology.

## Contribution, feedback, questions...

I you have any kind of feedback or questions - feel free to open an issue. If you'd like to propose an improvement or found a bug - start na issue as well, or feel free to fork and submit a pull request. Any kind of contributions would be much appreciated!












# The key differences

In comparison with traditional programming, instead of mutating the app state directly, you specify the mutations you want to happen in simple objects called *actions*. Also, to maintain consistency across entire app, developer does not need to do anything special, just refresh every observer with every update from `Dispatcher` based on current values of the part of `GlobalModel` that this observer is concerned about. This enforces developer to use "functional" approach on configuring observers - configuration logic becomes just a pure function of current state (represented by `GlobalModel`).

It's important that everything is stored in one single object that represents whole application state (content, meta-data, temporary data, etc.), but it's up to developer how to organize internal structure (nested objects/properties) of this object. There is also single dispatcher that manages whole app.

As the app grows, developer just need to extend `GlobalModel` to support the new features and behviours, as well as define new actions to implement new functionality and maintain new parts of `GlobalModel`.

# Extra benefits from using UniFlow

- every mutation of app state is easy to track and debug;
- it encourages developer to better design architectural solutions before writing code;
- allows significantly improve precision of estimates on development time.

# Swift 3 + Objective-C

For mixed environment Swift 3 + Objective-C use [version 1.1.1](https://github.com/maximkhatskevich/MKHUniFlow/releases/tag/1.1.1). For compatibility with Swift 2.2 and Swift 2.3 (as well as Objective-C) use [older version](https://github.com/maximkhatskevich/MKHUniFlow/releases/tag/1.0).

# Plans for future

Next major library update (v.2.*) will introduce significant change in how whole library works and supposed to be used. Also Objective-C support will be dropped (but it may be added later in future again).