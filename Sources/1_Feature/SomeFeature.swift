/*
 
 MIT License
 
 Copyright (c) 2016 Maxim Khatskevich (maxim@khatskevi.ch)
 
 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in all
 copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 SOFTWARE.
 
 */

/// Semantic marker that represents a Feature.
public
protocol SomeFeature: AnyObject
{
    /// Convenience helper that determines user-friendly feature name.
    static
    var displayName: String { get }
    
    /// Reference to a dispatcher in which context this feature
    /// should execute it's actions.
    var dispatcher: Dispatcher! { get }
}

//---

public
extension SomeFeature
{
    typealias Itself = Self
    
    /// `ByTypeStorage` will use this as actual key.
    static
    var name: String
    {
        .init(reflecting: Self.self)
    }

    static
    var displayName: String
    {
        name
    }
}

//---

/// These errors are being thrown by special helpers
/// that check if the feature is initialized or not
/// within given `Dispatcher`.
public
enum InitializationStatusCheckError: Error
{
    case alreadyInitialized(SomeFeature.Type)
    case notInitializedYet(SomeFeature.Type)
}

//---

public
extension SomeFeature
{
    /// Throws `InitializationStatusCheckError` if `self` is
    /// already initialized within `dispatcher`.
    func ensureAwaitingInitialization() throws
    {
        guard
            !dispatcher.hasValue(withKey: Self.self)
        else
        {
            throw InitializationStatusCheckError.alreadyInitialized(Self.self)
        }
    }
    
    /// Throws `InitializationStatusCheckError` if `self` is
    /// NOT initialized yet within `dispatcher`.
    func ensureAlreadyInitialized() throws
    {
        guard
            dispatcher.hasValue(withKey: Self.self)
        else
        {
            throw InitializationStatusCheckError.notInitializedYet(Self.self)
        }
    }
    
    /// Allows to fetch any state of any feature from `dispatcher`.
    @discardableResult
    func fetch<V: SomeState>(
        _ valueOfType: V.Type = V.self
    ) throws -> V {
        
        try dispatcher.fetch(
            valueOfType: V.self
        )
    }
    
    /// Save given state of `self` within `dispatcher` - either
    /// initialize, actuialize or transition into given `state`.
    func store<V: SomeState>(
        scope: String = #file,
        context: String = #function,
        location: Int = #line,
        _ value: V
    ) throws where V.Feature == Self {
        
        try dispatcher.access(scope: scope, context: context, location: location) {
            
            try $0.store(value)
        }
    }
    
    /// Attempts to initialize `self` into given `newState` within `dispatcher`
    /// or fails otherwise by throwing `SemanticMutationError`.
    func initialize<V: SomeState>(
        scope: String = #file,
        context: String = #function,
        location: Int = #line,
        with newValue: V
    ) throws where V.Feature == Self {
        
        try dispatcher.access(scope: scope, context: context, location: location) {
            
            try $0.initialize(with: newValue)
        }
    }
    
    /// Attempts to actualize `self` using given `mutationHandler` within `dispatcher`
    /// or fails otherwise by throwing `SemanticMutationError`.
    func actualize<V: SomeState>(
        scope: String = #file,
        context: String = #function,
        location: Int = #line,
        _ valueOfType: V.Type = V.self,
        via mutationHandler: (inout V) throws -> Void
    ) throws where V.Feature == Self {
        
        try dispatcher.access(scope: scope, context: context, location: location) {
           
            try $0.actualize(V.self, via: mutationHandler)
        }
    }
    
    /// Attempts to actualize `self` into given `newState` within `dispatcher`
    /// or fails otherwise by throwing `SemanticMutationError`.
    func actualize<V: SomeState>(
        scope: String = #file,
        context: String = #function,
        location: Int = #line,
        with newValue: V
    ) throws where V.Feature == Self {
        
        try dispatcher.access(scope: scope, context: context, location: location) {
           
            try $0.actualize(with: newValue)
        }
    }
    
    /// Attempts to transition `self` into given `newState` within `dispatcher`
    /// or fails otherwise by throwing `SemanticMutationError`.
    func transition<O: SomeState, N: SomeState>(
        scope: String = #file,
        context: String = #function,
        location: Int = #line,
        from oldValueInstance: O,
        into newValue: N
    ) throws where O.Feature == Self, N.Feature == Self {
        
        try dispatcher.access(scope: scope, context: context, location: location) {
           
            try $0.transition(from: oldValueInstance, into: newValue)
        }
    }
    
    /// Attempts to transition `self` into given `newState` within `dispatcher`
    /// or fails otherwise by throwing `SemanticMutationError`.
    func transition<O: SomeState, N: SomeState>(
        scope: String = #file,
        context: String = #function,
        location: Int = #line,
        from oldValueType: O.Type,
        into newValue: N
    ) throws where O.Feature == Self, N.Feature == Self {
        
        try dispatcher.access(scope: scope, context: context, location: location) {
           
            try $0.transition(from: O.self, into: newValue)
        }
    }
    
    /// Attempts to transition `self` into given `newState` within `dispatcher`
    /// or fails otherwise by throwing `SemanticMutationError`.
    func transition<V: SomeState>(
        scope: String = #file,
        context: String = #function,
        location: Int = #line,
        into newValue: V
    ) throws where V.Feature == Self {
        
        try dispatcher.access(scope: scope, context: context, location: location) {
           
            try $0.transition(into: newValue)
        }
    }
    
    /// Attempts to deinitialize `self` within `dispatcher`
    /// or fails otherwise by throwing `SemanticMutationError`.
    func deinitialize(
        scope: String = #file,
        context: String = #function,
        location: Int = #line,
        strict: Bool = true
    ) throws {
        
        try dispatcher.access(scope: scope, context: context, location: location) {
           
            try $0.deinitialize(Self.self, fromValueType: nil, strict: strict)
        }
    }
    
    /// Attempts to deinitialize `self` from given `fromState` within `dispatcher`
    /// or fails otherwise by throwing `SemanticMutationError`.
    func deinitialize<V: SomeState>(
        scope: String = #file,
        context: String = #function,
        location: Int = #line,
        from fromValueType: V.Type
    ) throws where V.Feature == Self {
        
        try dispatcher.access(scope: scope, context: context, location: location) {
           
            try $0.deinitialize(Self.self, fromValueType: fromValueType, strict: true)
        }
    }
}
