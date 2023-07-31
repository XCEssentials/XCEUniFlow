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
extension TransactionContext
{
    mutating
    func store<S: FeatureState>(
        scope s: String = #file,
        context c: String = #function,
        location l: Int = #line,
        _ state: S
    ) throws {

        try dispatcher
            .storage
            .store(
                scope: s,
                context: c,
                location: l,
                state
            )
    }

    // MARK: - Initialization

    @discardableResult
    func initialize<S: FeatureState>(
        scope s: String = #file,
        context c: String = #function,
        location l: Int = #line,
        with newState: S
    ) throws -> MutationAttemptOutcome {

        try dispatcher
            .storage
            .store(
                scope: s,
                context: c,
                location: l,
                newState,
                expectedMutation: .initialization
            )
    }

    // MARK: - Actualization

    @discardableResult
    func actualize<S: FeatureState>(
        scope s: String = #file,
        context c: String = #function,
        location l: Int = #line,
        with newState: S
    ) throws -> MutationAttemptOutcome {

        try dispatcher
            .storage
            .store(
                scope: s,
                context: c,
                location: l,
                newState,
                expectedMutation: .actualization
            )
    }

    @discardableResult
    func actualize<S: FeatureState>(
        scope s: String = #file,
        context c: String = #function,
        location l: Int = #line,
        _: S.Type = S.self,
        via mutationHandler: (inout S) throws -> Void
    ) throws -> MutationAttemptOutcome {

        guard
            var state = storage[S.self]
        else
        {
            throw AccessError.unexpectedCurrentState(
                expected: S.self,
                actual: storage[S.ParentFeature.self].map { type(of: $0) },
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

    // MARK: - Transition

    @discardableResult
    func transition<O: FeatureState, N: FeatureState>(
        scope s: String = #file,
        context c: String = #function,
        location l: Int = #line,
        from _: O, // for convenience - we can pass an instance, does not matter
        into newState: N
    ) throws -> MutationAttemptOutcome where O.ParentFeature == N.ParentFeature {

        try dispatcher
            .storage
            .store(
                scope: s,
                context: c,
                location: l,
                newState,
                expectedMutation: .transition(fromStateType: O.self)
            )
    }

    @discardableResult
    func transition<O: FeatureState, N: FeatureState>(
        scope s: String = #file,
        context c: String = #function,
        location l: Int = #line,
        from _: O.Type,
        into newState: N
    ) throws -> MutationAttemptOutcome where O.ParentFeature == N.ParentFeature {

        try dispatcher
            .storage
            .store(
                scope: s,
                context: c,
                location: l,
                newState,
                expectedMutation: .transition(fromStateType: O.self)
            )
    }

    @discardableResult
    func transition<S: FeatureState>(
        scope s: String = #file,
        context c: String = #function,
        location l: Int = #line,
        into newState: S
    ) throws -> MutationAttemptOutcome {

        try dispatcher
            .storage
            .store(
                scope: s,
                context: c,
                location: l,
                newState,
                expectedMutation: .transition(fromStateType: nil)
            )
    }

    // MARK: - Deinitialization

    @discardableResult
    func deinitialize<F: Feature>(
        scope s: String = #file,
        context c: String = #function,
        location l: Int = #line,
        strict: Bool = true,
        _: F.Type
    ) throws -> MutationAttemptOutcome {

        try dispatcher
            .storage
            .removeState(
                scope: s,
                context: c,
                location: l,
                forFeature: F.self,
                fromStateType: nil,
                strict: strict
            )
    }
    
    @discardableResult
    func deinitialize<S: FeatureState>(
        scope s: String = #file,
        context c: String = #function,
        location l: Int = #line,
        from _: S.Type
    ) throws -> MutationAttemptOutcome {
        
        try dispatcher
            .storage
            .removeState(
                scope: s,
                context: c,
                location: l,
                forFeature: S.ParentFeature.self,
                fromStateType: S.self,
                strict: true
            )
    }
    
    @discardableResult
    func deinitialize<S: FeatureState>(
        scope s: String = #file,
        context c: String = #function,
        location l: Int = #line,
        from _: S // we can receive instance for convenience
    ) throws -> MutationAttemptOutcome {
        
        try deinitialize(
            scope: s,
            context: c,
            location: l,
            from: S.self
        )
    }
}
