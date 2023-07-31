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

import Foundation

//---

public
struct StateStorage
{
    public
    typealias History = [MutationAttempt]
    
    internal private(set)
    var history: History = []
    
    private
    var data: [String: any FeatureState] = [:]
    
    //---
    
    //internal
    init() {}
}

// MARK: - GET data

public
extension StateStorage
{
    var allStates: [any FeatureState]
    {
        .init(data.values)
    }
    
    var allFeatures: [any Feature.Type]
    {
        allStates
            .map { type(of: $0).feature }
    }
    
    subscript(_ feature: any Feature.Type) -> (any FeatureState)?
    {
        data[feature.name]
    }
    
    func hasFeature(_ feature: any Feature.Type) -> Bool
    {
        self[feature] != nil
    }
    
    subscript<S: FeatureState>(_: S.Type) -> S?
    {
        data[S.ParentFeature.name] as? S
    }
    
    func hasState<S: FeatureState>(ofType _: S.Type) -> Bool
    {
        self[S.self] != nil
    }
    
    subscript<R: FeatureState, V>(_ keyPath: KeyPath<R, V>) -> V?
    {
        self[R.self]?[keyPath: keyPath]
    }
}

// MARK: - SET data

//internal
extension StateStorage
{
    @discardableResult
    mutating
    func store(
        file: StaticString = #file,
        function: StaticString = #function,
        line: UInt = #line,
        _ state: any FeatureState,
        expectedMutation: ExpectedMutation = .auto
    ) throws -> MutationAttemptOutcome {
        
        let proposedOutcome: MutationAttemptOutcome
        let featureName = type(of: state).feature.name
        
        //---
        
        switch (data[featureName], state)
        {
            case (.none, let newState):
                
                proposedOutcome = .initialization(newState: newState)
                
                //---
                
                try Self.validateProposedOutcome(
                    expected: expectedMutation,
                    proposed: proposedOutcome,
                    origin: .init(
                        file: file,
                        function: function,
                        line: line
                    )
                )
                
                //---
                
                data[featureName] = newState
                
            //---
                
            case (.some(let oldState), let newState):
                
                if
                    type(of: oldState) == type(of: newState)
                {
                    proposedOutcome = .actualization(oldState: oldState, newState: newState)
                }
                else
                {
                    proposedOutcome = .transition(oldState: oldState, newState: newState)
                }
                
                //---
                
                try Self.validateProposedOutcome(
                    expected: expectedMutation,
                    proposed: proposedOutcome,
                    origin: .init(
                        file: file,
                        function: function,
                        line: line
                    )
                )
                
                //---
                
                data[featureName] = newState
        }
        
        //---
              
        logHistoryEvent(outcome: proposedOutcome)
        
        //---
        
        return proposedOutcome
    }
}

// MARK: - REMOVE data

//internal
extension StateStorage
{
    @discardableResult
    mutating
    func removeState(
        file: StaticString = #file,
        function: StaticString = #function,
        line: UInt = #line,
        forFeature feature: Feature.Type,
        fromStateType: (any FeatureState.Type)? = nil,
        strict: Bool = true
    ) throws -> MutationAttemptOutcome {
        
        let implicitlyExpectedMutation: ExpectedMutation = .deinitialization(
            fromStateType: fromStateType,
            strict: strict
        )
        
        let proposedOutcome: MutationAttemptOutcome
        
        //---
        
        switch data[feature.name]
        {
            case .some(let oldState):
                
                proposedOutcome = .deinitialization(oldState: oldState)
                
                //---
                
                try Self.validateProposedOutcome(
                    expected: implicitlyExpectedMutation,
                    proposed: proposedOutcome,
                    origin: .init(
                        file: file,
                        function: function,
                        line: line
                    )
                )
                
                //---
                
                data.removeValue(forKey: feature.name)
                
            case .none:
                
                proposedOutcome = .nothingToRemove(feature: feature)
                
                //---
                
                try Self.validateProposedOutcome(
                    expected: implicitlyExpectedMutation,
                    proposed: proposedOutcome,
                    origin: .init(
                        file: file,
                        function: function,
                        line: line
                    )
                )
        }
        
        //---
              
        logHistoryEvent(outcome: proposedOutcome)
        
        //---
        
        return proposedOutcome
    }
    
    @discardableResult
    mutating
    func removeAll(
        file: StaticString = #file,
        function: StaticString = #function,
        line: UInt = #line
    ) throws -> [MutationAttemptOutcome] {
        
        try allFeatures
            .map {
                try removeState(
                    file: file,
                    function: function,
                    line: line,
                    forFeature: $0,
                    fromStateType: nil,
                    strict: false
                )
            }
    }
}

// MARK: - Semantic validation

//internal
extension StateStorage
{
    static
    func validateProposedOutcome(
        expected: ExpectedMutation,
        proposed: MutationAttemptOutcome,
        origin: AccessOrigin
    ) throws -> Void {
        
        switch (expected, proposed)
        {
            case (.auto, _):
                
                break // OK
                
            case (.initialization, .initialization):
                
                break // OK
                
            case (.actualization, .actualization):
                
                break  // OK
                
            case (.transition(.some(let givenStateType)), .transition(let oldState, _))
                where givenStateType == type(of: oldState):
                
                break // OK
                
            case (.transition(.none), .transition):
                
                break // OK
                
            case (.deinitialization(.some(let givenOldStateType), _), .deinitialization(let oldState))
                where givenOldStateType == type(of: oldState):
                
                break // OK
                
            case (.deinitialization(.none, _), .deinitialization):
                
                break // OK
                
            case (.deinitialization(.none, strict: false), .nothingToRemove):
                
                break // OK
                
            default:
                
                throw AccessError.semanticMismatch(
                    expectedMutation: expected,
                    proposedOutcome: proposed,
                    origin: origin
                )
        }
    }
}

// MARK: - History management

//internal
extension StateStorage
{
    private
    mutating
    func logHistoryEvent(
        outcome: MutationAttemptOutcome
    ) {
        
        history
            .append(
                .init(operation: outcome)
            )
    }
    
    /// Clear the history and return it's copy as result.
    mutating
    func resetHistory() -> History
    {
        let result = history
        history.removeAll()
        
        //---
        
        return result
    }
}
