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

public
extension Feature where Self: FeatureBase
{
    /// Save given state within `dispatcher` - either
    /// initialize, actuialize or transition into given `state`.
    ///
    /// NOTE: can be any feature, NOT onnly `self`.
    func store(
        scope: String = #file,
        context: String = #function,
        location: Int = #line,
        _ state: FeatureStateBase
    ) throws {
        
        try dispatcher.access(scope: scope, context: context, location: location) {
            
            try $0.store(state)
        }
    }
    
    /// Attempts to initialize `self` into given `newState` within `dispatcher`
    /// or fails otherwise by throwing `ExpectedMutation.SemanticError`.
    func initialize<S: FeatureState>(
        scope: String = #file,
        context: String = #function,
        location: Int = #line,
        with newState: S
    ) throws where S.ParentFeature == Self {
        
        try dispatcher.access(scope: scope, context: context, location: location) {
            
            try $0.initialize(with: newState)
        }
    }
    
    /// Attempts to actualize `self` using given `mutationHandler` within `dispatcher`
    /// or fails otherwise by throwing `ExpectedMutation.SemanticError`.
    func actualize<S: FeatureState>(
        scope: String = #file,
        context: String = #function,
        location: Int = #line,
        _: S.Type = S.self,
        via mutationHandler: (inout S) throws -> Void
    ) throws where S.ParentFeature == Self {
        
        try dispatcher.access(scope: scope, context: context, location: location) {
           
            try $0.actualize(S.self, via: mutationHandler)
        }
    }
    
    /// Attempts to actualize `self` into given `newState` within `dispatcher`
    /// or fails otherwise by throwing `ExpectedMutation.SemanticError`.
    func actualize<S: FeatureState>(
        scope: String = #file,
        context: String = #function,
        location: Int = #line,
        with newState: S
    ) throws where S.ParentFeature == Self {
        
        try dispatcher.access(scope: scope, context: context, location: location) {
           
            try $0.actualize(with: newState)
        }
    }
    
    /// Attempts to transition `self` into given `newState` within `dispatcher`
    /// or fails otherwise by throwing `ExpectedMutation.SemanticError`.
    func transition<O: FeatureState, N: FeatureState>(
        scope: String = #file,
        context: String = #function,
        location: Int = #line,
        from _: O, // for convenience - we can pass an instance, does not matter
        into newState: N
    ) throws where O.ParentFeature == Self, N.ParentFeature == Self {
        
        try dispatcher.access(scope: scope, context: context, location: location) {
           
            try $0.transition(from: O.self, into: newState)
        }
    }
    
    /// Attempts to transition `self` into given `newState` within `dispatcher`
    /// or fails otherwise by throwing `ExpectedMutation.SemanticError`.
    func transition<O: FeatureState, N: FeatureState>(
        scope: String = #file,
        context: String = #function,
        location: Int = #line,
        from _: O.Type,
        into newState: N
    ) throws where O.ParentFeature == Self, N.ParentFeature == Self {
        
        try dispatcher.access(scope: scope, context: context, location: location) {
           
            try $0.transition(from: O.self, into: newState)
        }
    }
    
    /// Attempts to transition `self` into given `newState` within `dispatcher`
    /// or fails otherwise by throwing `ExpectedMutation.SemanticError`.
    func transition<S: FeatureState>(
        scope: String = #file,
        context: String = #function,
        location: Int = #line,
        into newState: S
    ) throws where S.ParentFeature == Self {
        
        try dispatcher.access(scope: scope, context: context, location: location) {
           
            try $0.transition(into: newState)
        }
    }
    
    /// Attempts to deinitialize `self` within `dispatcher`
    /// or fails otherwise by throwing `ExpectedMutation.SemanticError`.
    func deinitialize(
        scope: String = #file,
        context: String = #function,
        location: Int = #line,
        strict: Bool = true
    ) throws {
        
        try dispatcher.access(scope: scope, context: context, location: location) {
           
            try $0.deinitialize(Self.self, fromStateType: nil, strict: strict)
        }
    }
    
    /// Attempts to deinitialize `self` from state `S` within `dispatcher`
    /// or fails otherwise by throwing `ExpectedMutation.SemanticError`.
    func deinitialize<S: FeatureState>(
        scope: String = #file,
        context: String = #function,
        location: Int = #line,
        from _: S.Type
    ) throws where S.ParentFeature == Self {
        
        try dispatcher.access(scope: scope, context: context, location: location) {
           
            try $0.deinitialize(Self.self, fromStateType: S.self, strict: true)
        }
    }
    
    /// Attempts to deinitialize `self` from state `S` within `dispatcher`
    /// or fails otherwise by throwing `ExpectedMutation.SemanticError`.
    func deinitialize<S: FeatureState>(
        scope: String = #file,
        context: String = #function,
        location: Int = #line,
        from _: S
    ) throws where S.ParentFeature == Self {
        
        try deinitialize(
            scope: scope,
            context: context,
            location: location,
            from: S.self
        )
    }
}
