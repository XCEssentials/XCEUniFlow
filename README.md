# Introduction

**UniFlow** is a predictable state container for iOS and macOS apps.

This framework implements so-called 'Unidirectional Data Flow' paradigm for developing applications for iOS and macOS platforms. The key idea behind it is just [state machine](https://en.wikipedia.org/wiki/Finite-state_machine).

# Motivation

A framework like this should be a tool that helps and inspire to:

1. make the app completely predictable at any moment of (execution) time;
2. effectivly exchange/share data between different scopes (without having to store and maintain direct cross-references in many-to-many style) so all parts of the app (including all UIs) stay consistent all the time;
3. eliminate implicit [side effects](https://en.wikipedia.org/wiki/Side_effect_(computer_science)) in application source code;
4. make the app source code well structured - easy to read, understand and reason about;
5. make the app source code compatible with key software design principle (like [Separation of concerns](https://en.wikipedia.org/wiki/Separation_of_concerns), [Encapsulation](https://en.wikipedia.org/wiki/Information_hiding#Encapsulation), [Black box](https://en.wikipedia.org/wiki/Black_box), [Dependency Injection](https://en.wikipedia.org/wiki/Dependency_injection));
6. make the app source code compatible with key architectural patterns (like [MVVM](https://en.wikipedia.org/wiki/Model%E2%80%93view%E2%80%93viewmodel), [MVC](https://en.wikipedia.org/wiki/Model%E2%80%93view%E2%80%93controller)).
7. make the app source code easily translatable to/from [BDD](https://en.wikipedia.org/wiki/Behavior-driven_development) specifications;
8. make application source code ready for unit tests (including independent module testing and integration testing);
9. keep developer written source code minimal and compact (make it look like specifications);
10. keep library overhead as low as possible (no run-time "magic" should be involved). 

# Inspiration

Thanks to:
- [Facebook](facebook.com) and their [Flux](https://facebook.github.io/flux/) framework for web development, where the idea originally comes from;
- [Redux](https://github.com/reactjs/redux) JavaScript framework.
- [ReSwift](https://github.com/ReSwift/ReSwift) which is the most similar implementation of the idea for Apple platforms.

# Key concepts

The whole state of the app is stored in a single object called `GlobalModel`. After initialization, `GlobalModel` is being passed as input parameter into `Dispatcher` initialization function and being stored inside `Dispatcher`, isolated from the rest of the world. Developer has NO direct access to `GlobalModel` anymore. 

The only way to change the state object is to emit (submit to `Dispatcher`) an `Action`. In most cases, `Action` supposed to mutate the `GlobalModel` stored inside `Dispatcher`.

The only way to access/consume the state object is to subscribe for notifications from `Dispatcher` which are being sent every time an `Action` has been successfully processed.

## GlobalModel

`GlobalModel` is the object that represents all possible states of the app (including UI state). It also contains all (source, non-derived) data that is needed in order the app to function properly, including any content that should be displayed in UI and any meta-data (parameters, temporary values, etc.) about how this content should be displayed/represented.

## Action

In general case, every `Action` defines an atomic piece of [business logic](https://en.wikipedia.org/wiki/Business_logic) (like a step in an operation, initialization of an operation, etc.) or [presentation logic](https://en.wikipedia.org/wiki/Presentation_logic) that mutates `GlobalModel`.

Optionally, `Action` may contain any kind of internal data that represents input parameters for the logic behind this action. This is how developer can bring any kind of data/input from the outer world (user input, data from system notifications, etc.).

There are two special (helper) types of `Action`:
- `Trigger` is an action that is not supposed to mutate `GlobalModel` directly, but only emit other action(s);
- `Notification` is an action that is not supposed to mutate `GlobalModel` or even do anything at all (think about it as a "pure" system-wide notification, that still can contain some attached data and will deliver it to all subscribers of `Dispatcher`).

## Subscriptions

If an object in the app needs to have access to current app state (`GlobalModel`), then it needs to be subscribed for updates from `Dispatcher` and become *observer*. Every time the `Dispatcher` successfully processed an action - it notifies every *observer* one by one, in the order as they subscribed.

## Dispatcher

`Dispatcher` is the central point of communication between different parts/components of the app, it is responsible for the tasks listed below.

- store current application state;
- process actions;
- maintain (create, store, notify and remove) subscriptions.

# The key differences

In comparison with traditional programming, instead of mutating the app state directly, you specify the mutations you want to happen in simple objects called *actions*. Also, to maintain consistency across entire app, developer does not need to do anything special, just refresh every observer with every update from `Dispatcher` based on current values of the part of `GlobalModel` that this observer is concerned about. This enforces developer to use "functional" approach on configuring observers - configuration logic becomes just a pure function of current state (represented by `GlobalModel`).

It's important that everything is stored in one single object that represents whole application state (content, meta-data, temporary data, etc.), but it's up to developer how to organize internal structure (nested objects/properties) of this object. There is also single dispatcher that manages whole app.

As the app grows, developer just need to extend `GlobalModel` to support the new features and behviours, as well as define new actions to implement new functionality and maintain new parts of `GlobalModel`.

# Why ReSwift is NOT good enough?

Below are the weak points of [ReSwift](https://github.com/ReSwift/ReSwift).

## Overhead with Reducer implementation

1. *Reducer* is not supposed to have any internal state/data ever, so the only value of *reducer* is the logic that can be easily represented as a pure function (with input parameters), so it doesn't make sense to have *reducer* as an object/instance and implement it's functionality as instance member/function.
2. The way *reducers* are supposed to be implemented adds unnecessary "manual" work to developer and very likely will lead to errors/mistakes as the codebase grows. In particular, developer has to implement every *reducer* as an object/struct and then always remember (during application and *store* initialization) to create exactly one instance of each *reducer* and explicitly register it in the *store*. Otherwise, *reducer* will not be included in the *actions* processing chain and silently will not work.
3. Entire library architecture promotes very strange and inconvenent way of organizing app logic/code. Each *action* supposed to represet only data model needed for the logic related to this *action*, while logic itself is spread across one or multiple *reducers*. The only way to recall/understand what a particular *action* does, without having detailed up-to-date documentation, is to search across whole app for *reducsers* which react to that specific *action*. That's a nightmare for developer, leads to lack of understanding of big picture by developer and, as result - to errors/bugs/crashes in the app and pure overall app UX.
4. The way *reducer* main function expected to be written is far from perfect. While it may look cool because it's pure "functional" approach, it's lot of manual work for developer that implements app functionality. We have to do check/unwrap optional *state* in every single reducer, before we even start to write any app-specific code, which is just ridiculous - why wouldn't we have the 'state' set at any moment of application life time? Plus, it comes as read-only input parameter and you HAVE to return a state value, even if this action made no mutations on state at all - that all makes developer (in most cases) to explicitly unwrap optional input state into a variable ("var"). We also do not know what the *action* is and have to always optionally typecast it or at least check its type. That's lot of unnecessary complications that make the logic behind the source code hard to read and understand, so, again, it's very error-prone.

## Subscription mechanism limitations

The subscription mechanism requires:

1. *observer* to have a specific method implemented (conform to protocol) that limits developer with naming;
2. this specific method (*newState*) receives optional value, that require the code to always have unwrapping code before any app-specific code comes, which is on a big scale a big unnecessary manual work to be done by developer.

## Middleware

*Middleware* seems to be absolutely overkill/unnecessary complication, even a simple example looks super complicated.

# Extra benefits from using UniFlow

- every mutation of app state is easy to track and debug;
- it encourages developer to better design architectural solutions before writing code;
- allows significantly improve precision of estimations on development time.

# Swift 3 + Objective-C

For mixed environment Swift 3 + Objective-C use [version 1.1.1](https://github.com/maximkhatskevich/MKHUniFlow/releases/tag/1.1.1). For compatibility with Swift 2.2 and Swift 2.3 (as well as Objective-C) use [older version](https://github.com/maximkhatskevich/MKHUniFlow/releases/tag/1.0).

# Plans for future

Next major library update (v.2.*) will introduce significant change in how whole library works and supposed to be used. Also Objective-C support will be dropped (but it may be added later in future again).