[![GitHub tag](https://img.shields.io/github/tag/XCEssentials/Requirement.svg)](https://cocoapods.org/?q=XCERequirement)
[![license](https://img.shields.io/github/license/XCEssentials/Requirement.svg)](https://opensource.org/licenses/MIT)
[![CocoaPods](https://img.shields.io/cocoapods/v/XCERequirement.svg)](https://cocoapods.org/?q=XCERequirement)
[![CocoaPods](https://img.shields.io/cocoapods/p/XCERequirement.svg)](https://cocoapods.org/?q=XCEUniFlow)

# Problem

When it comes to definition of how an app should work, there are many [requirements](https://en.wikipedia.org/wiki/Requirement) that should be implemented in source code. Every requirement, obviously, can be described in a human-friendly language, as well as formalized in a programming languge (computer-friendly).

# Pre-existing solutions

Usually requirements are being implemented in a batch as part of a task/model/etc. without direct transition of specific requirement into exact line/range of source code in the app.

In most cases, every single requirement from specification (task definition) is being translated into some code in data model or business logic and that's it. That means there is not much semantics provided by such implementation - if this requirement is not fullfilled, it's not clear how to report the issue formally to the outer scope and/or in human-friendly format to the user (via GUI). If such reporting is implemented - it usually leads to spreading of the requirement implementation into few different parts: actual requirement check, how it's being represented for fromal reporting to outer scope, and how it is being represented for human-friendly reporting via GUI.

Such implementation of requirements is hard to test/validate, keep consistent over time (when minor changes happen in a given requirement) and makes source code hard to understand and reason about.

# Wishlist

Ideally there should be a tool that allows:

1. bind requirement human-friendly description (variable length text) and its computer-friendly formal representation (piece of code) together in a single statement;
2. keep focus on content, make the wrapping expressions as minimal as possible;
3. automate requirement validation and success/failure reporting to both outer scope and GUI.

# Methodology overview

Each requirement can be evaluated against a given data value (which can be an atomic or complex data type). In the other words, every requirement definition can be represented in form of a function that takes one or several input parameters and returns `Boolean` value - `true` means that requirement is fullfilled with provided input values, and `false` means the opposite.

# How to install

The recommended way is to install using [CocoaPods](https://cocoapods.org/?q=XCERequirement).

# How it works

It's a small and very simple, yet powerful library.

`Requirement` is the main data type that actually represents requirement. Note, that this is a `struct`, so once it's created, it works as a single atomic value.

To define a requirement, create an instace of `Requirement`. Its consturctor accepts two necessary parameters - human friendly description in form of a `String` and a closure that implements formal representation. Moreover, `Requirement` is a generic type, `Input` generic type represents the type of expected input parameters for the closure.

# How to use

Here is an example of how to create a requirements, that an integer number should not be equal to zero.

```swift
let r = Requirement<Int>("Non-zero") { $0 != 0 }
```

Same can be achived by using a helper typealias `Require`:

```swift
let r = Require<Int>("Non-zero") { $0 != 0 }
```

In the example above we created an instace of `Requirement` that supposed to evaluate values of type `Int`. We pass a string as the only parameter of constructor function, while second parameter (the closure) is being passed as trailing closures. Moreover, the only input parameter of the closure is represented by `$0`, which is a shorthand argument name. See more in the official Apple [docs](https://developer.apple.com/library/content/documentation/Swift/Conceptual/Swift_Programming_Language/Closures.html).

Note, that If a requirement contains phrases like **AND**, **OR** or any other logical [operators](https://en.wikipedia.org/wiki/Operator_(mathematics)), then such requirement should be divided into independent requirements, or the input parameter might be represented as a complex data type like `struct` or `tuple`.

When requirement is created, here is an example of how it might be used for checking potentially suitable values.

```swift
if
    r.isFulfilled(with: 14) // returns Bool
{
	// given value - 14 (Int) - fulfill the requirement

	// r.title - the description that has been provided
	// at requirement creation point
	
    print("\(r.title) -> YES")
}
else
{
	// this code block will be executed,
    // if 0 will be passed into the r.isFulfilled(...)
	
    print("\(r.title) -> NO")
}
```

Same check can be done by utilizing Swift [error handling](https://developer.apple.com/library/content/documentation/Swift/Conceptual/Swift_Programming_Language/ErrorHandling.html), see example below.

```swift
do
{
    try r.check(with: 0) // this will throw exception
}
catch
{
    print(error) // error has 'RequirementNotFulfilled' type
}
```

The `RequirementNotFulfilled` data type has two parameters:

- `let requirement: String` that contains description of the requirement;
- `let input: Any` that contains exact input data value that has been evaluated and failed to fulfill the requirement.

## Inline helpers

While `Requirement` itself might be more useful to implement **[data model](https://en.wikipedia.org/wiki/Data_model)**, there are several helpers, that use the same idea, but provide special API that is more convenient for inline use when implementing **[business logic](https://en.wikipedia.org/wiki/Business_logic)**. These helpers are incapsulated into special `enum` called `REQ`, they all throw an instace of `VerificationFailed` error when requirement is not fulfilled, some of them may return a value that can be used further in the code.

When you have an `Optional` value or you have a function/closure that produces `Optional` value, and you need this value only if it's NOT `nil`, or throw an error otherwise:

```swift
let nonNilValue = try REQ.value("Value is NOT nil") {
	
	// return here an optional value,
	// it might be result of an expression 
	// or an optional value captured from the outer scope,
	// will throw if value is 'nil' or just return
	// non-Optional value overwise
}
```

Same as the above, but does not return a anything. When you have an `Optional` value or you have a function/closure that produces `Optional` value, and you need to make sure that this value is NOT `nil`, or throw an error otherwise:

```swift
try REQ.isNotNil("Value is NOT nil") { // does not return anything
	
	// return here an optional value,
	// it might be result of an expression 
	// or an optional value captured from the outer scope,
	// will throw if value IS 'nil' or pass through
	// silently otherwise
}
```

When you have an `Optional` value or you have a function/closure that produces `Optional` value, and you need to make sure that this value IS `nil`, or throw an error otherwise:

```swift
try REQ.isNil("Value IS nil") { // does not return anything
	
	// return here an optional value,
	// it might be result of an expression 
	// or an optional value captured from the outer scope,
	// will throw if value is NOT 'nil' or pass through
	// silently otherwise
}
```

When you have an `Bool` value or you have a function/closure that produces `Bool` value, and you want to continue only if it's `true`, or throw an error otherwise (if it's `false`):

```swift
try REQ.isTrue("Value is TRUE") { // does not return anything
	
	// return here a boolean value,
	// it might be result of an expression 
	// or an boolean value captured from the outer scope,
	// will throw if value is 'false' or pass through
	// silently otherwise
}
```

The `VerificationFailed` data type has the only parameter:

- `let description: String` that contains the requirement description passed to the corresponding `REQ.*` function.