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
extension ByTypeStorage
{
    struct SemanticMutationError: Error
    {
        public
        let expectedMutation: ExpectedMutation
        
        public
        let proposedOutcome: MutationAttemptOutcome
    }
    
    enum ExpectedMutation
    {
        case auto
        case initialization
        case actualization
        case transition(fromValueType: SomeStorableBase.Type?)
        case deinitialization(fromValueType: SomeStorableBase.Type?, strict: Bool)
        
        func validateProposedOutcome(_ outcome: MutationAttemptOutcome) throws -> Void
        {
            switch (self, outcome)
            {
                case (.auto, _):
                    
                    break // OK
                    
                case (.initialization, .initialization):
                    
                    break // OK
                    
                case (.actualization, .actualization):
                    
                    break  // OK
                    
                case (.transition(.some(let givenOldValueType)), .transition(_, let oldValue, _))
                    where givenOldValueType == type(of: oldValue):
                    
                    break // OK
                    
                case (.transition(.none), .transition):
                    
                    break // OK
                    
                case (.deinitialization(.some(let givenOldValueType), _), .deinitialization(let oldValue, _))
                    where givenOldValueType == type(of: oldValue):
                    
                    break // OK
                    
                case (.deinitialization(.none, _), .deinitialization):
                    
                    break // OK
                    
                case (.deinitialization(.none, strict: false), .nothingToRemove):
                    
                    break // OK
                    
                default:
                    throw SemanticMutationError(
                        expectedMutation: self,
                        proposedOutcome: outcome
                    )
            }
        }
    }
}
    
// MARK: - Initialization

public
extension ByTypeStorage
{
    @discardableResult
    mutating
    func initialize<V: SomeStorable>(
        with newValue: V
    ) throws -> MutationAttemptOutcome {
        
        try store(
            newValue,
            expectedMutation: .initialization
        )
    }
}

// MARK: - Actualization

public
extension ByTypeStorage
{
    @discardableResult
    mutating
    func actualize<V: SomeStorable>(
        _: V.Type = V.self,
        via mutationHandler: (inout V) throws -> Void
    ) throws -> MutationAttemptOutcome {
        
        var state: V = try fetch()
        
        //---
        
        try mutationHandler(&state)
        
        //---
        
        return try actualize(with: state)
    }
    
    @discardableResult
    mutating
    func actualize<V: SomeStorable>(
        with newValue: V
    ) throws -> MutationAttemptOutcome {
        
        try store(
            newValue,
            expectedMutation: .actualization
        )
    }
}

// MARK: - Transition

public
extension ByTypeStorage
{
    @discardableResult
    mutating
    func transition<O: SomeStorable, N: SomeStorable>(
        from _: O,
        into newValue: N
    ) throws -> MutationAttemptOutcome where O.Key == N.Key /* NOTE: "O != N" is implied*/ {
        
        try transition(
            from: O.self,
            into: newValue
        )
    }
    
    @discardableResult
    mutating
    func transition<O: SomeStorable, N: SomeStorable>(
        from _: O.Type,
        into newValue: N
    ) throws -> MutationAttemptOutcome where O.Key == N.Key /* NOTE: "O != N" is implied*/ {
        
        try store(
            newValue,
            expectedMutation: .transition(fromValueType: O.self)
        )
    }
    
    /// Transition edge case where we've been given same type for both old and new value,
    /// so in best case scenario it is going to be actualization.
    @discardableResult
    mutating
    func transition<V: SomeStorable>(
        from _: V.Type,
        into newValue: V
    ) throws -> MutationAttemptOutcome {
        
        try store(
            newValue,
            expectedMutation: .actualization // we explicitly set expectations by using same type
        )
    }
    
    @discardableResult
    mutating
    func transition<V: SomeStorable>(
        into newValue: V
    ) throws -> MutationAttemptOutcome {
        
        try store(
            newValue,
            expectedMutation: .transition(fromValueType: nil)
        )
    }
}

// MARK: - Deinitialization

public
extension ByTypeStorage
{
    @discardableResult
    mutating
    func deinitialize(
        _ keyType: SomeFeatureBase.Type,
        fromValueType: SomeStorableBase.Type?, // = nil,
        strict: Bool // = true
    ) throws -> MutationAttemptOutcome {
        
        try removeValue(
            forKey: keyType,
            fromValueType: fromValueType,
            strict: strict
        )
    }
}

