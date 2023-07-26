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
    
// MARK: - Initialization

//internal
extension StateStorage
{
    @discardableResult
    mutating
    func initialize<S: FeatureState>(
        scope s: String = #file,
        context c: String = #function,
        location l: Int = #line,
        with newState: S
    ) throws -> MutationAttemptOutcome {
        
        try store(
            scope: s,
            context: c,
            location: l,
            newState,
            expectedMutation: .initialization
        )
    }
}

// MARK: - Actualization

//internal
extension StateStorage
{
    @discardableResult
    mutating
    func actualize<S: FeatureState>(
        scope s: String = #file,
        context c: String = #function,
        location l: Int = #line,
        _: S.Type = S.self,
        via mutationHandler: (inout S) throws -> Void
    ) throws -> MutationAttemptOutcome {
        
        guard
            var state = self[S.self]
        else
        {
            throw AccessError.unexpectedCurrentState(
                expected: S.self,
                actual: self[S.ParentFeature.self].map { type(of: $0) },
                origin: .init(
                    file: s,
                    function: c,
                    line: l
                )
            )
        }
        
        //---
        
        try mutationHandler(&state)
        
        //---
        
        return try actualize(
            scope: s,
            context: c,
            location: l,
            with: state
        )
    }
    
    @discardableResult
    mutating
    func actualize<S: FeatureState>(
        scope s: String = #file,
        context c: String = #function,
        location l: Int = #line,
        with newState: S
    ) throws -> MutationAttemptOutcome {
        
        try store(
            scope: s,
            context: c,
            location: l,
            newState,
            expectedMutation: .actualization
        )
    }
}

// MARK: - Transition

//internal
extension StateStorage
{
    @discardableResult
    mutating
    func transition<O: FeatureState, N: FeatureState>(
        scope s: String = #file,
        context c: String = #function,
        location l: Int = #line,
        from _: O.Type,
        into newState: N
    ) throws -> MutationAttemptOutcome where O.ParentFeature == N.ParentFeature /* NOTE: "O != N" is implied*/ {
        
        try store(
            scope: s,
            context: c,
            location: l,
            newState,
            expectedMutation: .transition(fromStateType: O.self)
        )
    }
    
    /// Transition edge case where we've been given same type for both old and new states,
    /// so in best case scenario it is going to be actualization.
    @discardableResult
    mutating
    func transition<S: FeatureState>(
        scope s: String = #file,
        context c: String = #function,
        location l: Int = #line,
        from _: S.Type,
        into newState: S
    ) throws -> MutationAttemptOutcome {
        
        // NOTE: we explicitly set expectations by using same type
        
        try store(
            scope: s,
            context: c,
            location: l,
            newState,
            expectedMutation: .actualization
        )
    }
    
    @discardableResult
    mutating
    func transition<S: FeatureState>(
        scope s: String = #file,
        context c: String = #function,
        location l: Int = #line,
        into newState: S
    ) throws -> MutationAttemptOutcome {
        
        try store(
            scope: s,
            context: c,
            location: l,
            newState,
            expectedMutation: .transition(fromStateType: nil)
        )
    }
}

// MARK: - Deinitialization

//internal
extension StateStorage
{
    @discardableResult
    mutating
    func deinitialize(
        scope s: String = #file,
        context c: String = #function,
        location l: Int = #line,
        _ feature: Feature.Type,
        fromStateType: (any FeatureState.Type)?, // = nil,
        strict: Bool // = true
    ) throws -> MutationAttemptOutcome {
        
        try removeState(
            scope: s,
            context: c,
            location: l,
            forFeature: feature,
            fromStateType: fromStateType,
            strict: strict
        )
    }
}

