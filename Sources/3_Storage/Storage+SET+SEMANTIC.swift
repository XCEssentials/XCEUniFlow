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

public
extension Storage
{
    @discardableResult
    mutating
    func initialize<S: SomeState>(
        with newState: S
    ) throws -> MutationAttemptOutcome {
        
        try store(
            newState,
            expectedMutation: .initialization
        )
    }
}

// MARK: - Actualization

public
extension Storage
{
    @discardableResult
    mutating
    func actualize<S: SomeState>(
        _: S.Type = S.self,
        via mutationHandler: (inout S) throws -> Void
    ) throws -> MutationAttemptOutcome {
        
        var state: S = try fetchState()
        
        //---
        
        try mutationHandler(&state)
        
        //---
        
        return try actualize(with: state)
    }
    
    @discardableResult
    mutating
    func actualize<S: SomeState>(
        with newState: S
    ) throws -> MutationAttemptOutcome {
        
        try store(
            newState,
            expectedMutation: .actualization
        )
    }
}

// MARK: - Transition

public
extension Storage
{
    @discardableResult
    mutating
    func transition<O: SomeState, N: SomeState>(
        from _: O.Type,
        into newState: N
    ) throws -> MutationAttemptOutcome where O.Feature == N.Feature /* NOTE: "O != N" is implied*/ {
        
        try store(
            newState,
            expectedMutation: .transition(fromStateType: O.self)
        )
    }
    
    /// Transition edge case where we've been given same type for both old and new states,
    /// so in best case scenario it is going to be actualization.
    @discardableResult
    mutating
    func transition<S: SomeState>(
        from _: S.Type,
        into newState: S
    ) throws -> MutationAttemptOutcome {
        
        try store(
            newState,
            expectedMutation: .actualization // we explicitly set expectations by using same type
        )
    }
    
    @discardableResult
    mutating
    func transition<S: SomeState>(
        into newState: S
    ) throws -> MutationAttemptOutcome {
        
        try store(
            newState,
            expectedMutation: .transition(fromStateType: nil)
        )
    }
}

// MARK: - Deinitialization

public
extension Storage
{
    @discardableResult
    mutating
    func deinitialize(
        _ feature: SomeFeature.Type,
        fromStateType: SomeStateBase.Type?, // = nil,
        strict: Bool // = true
    ) throws -> MutationAttemptOutcome {
        
        try removeState(
            forFeature: feature,
            fromStateType: fromStateType,
            strict: strict
        )
    }
}

