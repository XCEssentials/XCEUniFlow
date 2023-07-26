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

/// Special wrapper that allows mutations for feature `F` within transaction,
/// as well as read-only access to in-transaction copy of `storage`
/// from `Dispatcher`.
@MainActor
public
struct TransactionContext<F: Feature>
{
    public private(set)
    var storage: StateStorage
}

public
extension TransactionContext
{
    mutating
    func store<S: FeatureState>(
        scope s: String = #file,
        context c: String = #function,
        location l: Int = #line,
        _ state: S
    ) throws where S.ParentFeature == F {

        try storage
            .store(
                scope: s,
                context: c,
                location: l,
                state
            )
    }

    mutating
    func initialize<S: FeatureState>(
        scope s: String = #file,
        context c: String = #function,
        location l: Int = #line,
        with newState: S
    ) throws where S.ParentFeature == F {

        try storage
            .initialize(
                scope: s,
                context: c,
                location: l,
                with: newState
            )
    }

    mutating
    func actualize<S: FeatureState>(
        scope s: String = #file,
        context c: String = #function,
        location l: Int = #line,
        _: S.Type = S.self,
        via mutationHandler: (inout S) throws -> Void
    ) throws where S.ParentFeature == F {

        try storage
            .actualize(
                scope: s,
                context: c,
                location: l,
                S.self,
                via: mutationHandler
            )
    }

    mutating
    func actualize<S: FeatureState>(
        scope s: String = #file,
        context c: String = #function,
        location l: Int = #line,
        with newState: S
    ) throws where S.ParentFeature == F {

        try storage
            .actualize(
                scope: s,
                context: c,
                location: l,
                with: newState
            )
    }

    mutating
    func transition<O: FeatureState, N: FeatureState>(
        scope s: String = #file,
        context c: String = #function,
        location l: Int = #line,
        from _: O, // for convenience - we can pass an instance, does not matter
        into newState: N
    ) throws where O.ParentFeature == F, N.ParentFeature == F {

        try storage
            .transition(
                scope: s,
                context: c,
                location: l,
                from: O.self,
                into: newState
            )
    }

    mutating
    func transition<O: FeatureState, N: FeatureState>(
        scope s: String = #file,
        context c: String = #function,
        location l: Int = #line,
        from _: O.Type,
        into newState: N
    ) throws where O.ParentFeature == F, N.ParentFeature == F {

        try storage
            .transition(
                scope: s,
                context: c,
                location: l,
                from: O.self,
                into: newState
            )
    }

    mutating
    func transition<S: FeatureState>(
        scope s: String = #file,
        context c: String = #function,
        location l: Int = #line,
        into newState: S
    ) throws where S.ParentFeature == F {

        try storage
            .transition(
                scope: s,
                context: c,
                location: l,
                into: newState
            )
    }

    mutating
    func deinitialize(
        scope s: String = #file,
        context c: String = #function,
        location l: Int = #line,
        strict: Bool = true
    ) throws {

        try storage
            .deinitialize(
                scope: s,
                context: c,
                location: l,
                F.self,
                fromStateType: nil,
                strict: strict
            )
    }
    
    mutating
    func deinitialize<S: FeatureState>(
        scope s: String = #file,
        context c: String = #function,
        location l: Int = #line,
        from _: S.Type
    ) throws where S.ParentFeature == F {
        
        try storage
            .deinitialize(
                scope: s,
                context: c,
                location: l,
                F.self,
                fromStateType: S.self,
                strict: true
            )
    }
    
    mutating
    func deinitialize<S: FeatureState>(
        scope s: String = #file,
        context c: String = #function,
        location l: Int = #line,
        from _: S
    ) throws where S.ParentFeature == F {
        
        try deinitialize(
            scope: s,
            context: c,
            location: l,
            from: S.self
        )
    }
}
