[![license](https://img.shields.io/github/license/XCEssentials/Testing.svg)](https://opensource.org/licenses/MIT)
[![GitHub tag](https://img.shields.io/github/tag/XCEssentials/Testing.svg)](https://cocoapods.org/?q=XCERequirement)
[![CocoaPods](https://img.shields.io/cocoapods/v/XCETesting.svg)](https://cocoapods.org/?q=XCERequirement)
[![CocoaPods](https://img.shields.io/cocoapods/p/XCETesting.svg)](https://cocoapods.org/?q=XCEUniFlow)


# Problem

Every unit test represents one or several [requirements](https://en.wikipedia.org/wiki/Requirement). Standard Xcode API (XCTest framework) provides very basic expressions that work well, but the result code is not very concise and easy to read/understand.

# Wishlist

1. make the result code concise and self-expressive;
2. allow to express requirement as closure (so it can consist of single value, expression or multiple expressions);
3. allow to return value from a check.

# How to install

The recommended way is to install using [CocoaPods](https://cocoapods.org/?q=XCETesting).

# How it works

The library provides number of helper functions, each of these functions accept requirement description and closure, that returns the value that will be evaluated (and returned for some functions).

# How to use

When you have an `Optional` value or you have a function/closure that produces `Optional` value, and you need this value only if it's NOT `nil`, or call `XCTFail` otherwise:

```swift
let nonNilValue = try RXC.value("Value is NOT nil") {
	
	// return here an optional value,
	// it might be result of an expression 
	// or an optional value captured from the outer scope,
	// will call 'XCTFail' if value IS 'nil' or just return
	// non-Optional value overwise
}
```

Same as the above, but does not return a anything. When you have an `Optional` value or you have a function/closure that produces `Optional` value, and you need to make sure that this value is NOT `nil`, or call `XCTFail` otherwise:

```swift
try RXC.isNotNil("Value is NOT nil") { // does not return anything
	
	// return here an optional value,
	// it might be result of an expression 
	// or an optional value captured from the outer scope,
	// will call 'XCTFail' if value IS 'nil' or pass through
	// silently otherwise
}
```

When you have an `Optional` value or you have a function/closure that produces `Optional` value, and you need to make sure that this value IS `nil`, or call `XCTFail` otherwise:

```swift
try RXC.isNil("Value IS nil") { // does not return anything
	
	// return here an optional value,
	// it might be result of an expression 
	// or an optional value captured from the outer scope,
	// will call 'XCTFail' if value is NOT 'nil' or pass through
	// silently otherwise
}
```

When you have an `Bool` value or you have a function/closure that produces `Bool` value, and you want to continue only if it's `true`, or call `XCTFail` otherwise (if it's `false`):

```swift
try RXC.isTrue("Value is TRUE") { // does not return anything
	
	// return here a boolean value,
	// it might be result of an expression 
	// or an boolean value captured from the outer scope,
	// will call 'XCTFail' if value is 'false' or pass through
	// silently otherwise
}
```

The `VerificationFailed` data type has the only parameter:

- `let description: String` that contains the requirement description passed to the corresponding `RXC.*` function.
