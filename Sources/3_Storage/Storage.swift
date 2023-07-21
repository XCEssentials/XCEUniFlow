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
struct Storage
{
    private
    var data: [String: SomeStateBase] = [:]
    
    public private(set)
    var history: History = []
    
    public private(set)
    var lastHistoryResetId: String = UUID().uuidString
    
    //---
    
    public
    init() {}
}

// MARK: - Nested types

public
extension Storage
{
    enum ReadDataError: Error
    {
        case featureNotFound(
            SomeFeature.Type
        )
        
        case stateTypeMismatch(
            feature: SomeFeature.Type,
            expected: SomeStateBase.Type,
            actual: SomeStateBase
        )
    }
}

// MARK: - GET data

public
extension Storage
{
    var allStates: [SomeStateBase]
    {
        .init(data.values)
    }
    
    var allFeatures: [SomeFeature.Type]
    {
        allStates
            .map {
                type(of: $0).feature
            }
    }
    
    func fetchState(forFeature featureType: SomeFeature.Type) throws -> SomeStateBase
    {
        if
            let result = data[featureType.name]
        {
            return result
        }
        else
        {
            throw ReadDataError.featureNotFound(featureType)
        }
    }
    
    func fetchState<S: FeatureState>(ofType _: S.Type = S.self) throws -> S
    {
        let someState = try fetchState(forFeature: S.ParentFeature.self)
        
        //---
        
        if
            let result = someState as? S
        {
            return result
        }
        else
        {
            throw ReadDataError.stateTypeMismatch(
                feature: S.ParentFeature.self,
                expected: S.self,
                actual: someState
            )
        }
    }
}

// MARK: - SET data

public
extension Storage
{
    @discardableResult
    mutating
    func store(
        _ state: SomeStateBase,
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
                
                try SemanticError.validateProposedOutcome(
                    expected: expectedMutation,
                    proposed: proposedOutcome
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
                
                try SemanticError.validateProposedOutcome(
                    expected: expectedMutation,
                    proposed: proposedOutcome
                )
                
                //---
                
                data[featureName] = newState
        }
        
        //---
              
        logHistoryEvent(
            outcome: proposedOutcome
        )
        
        //---
        
        return proposedOutcome
    }
}

// MARK: - REMOVE data

public
extension Storage
{
    @discardableResult
    mutating
    func removeState(
        forFeature feature: SomeFeature.Type,
        fromStateType: SomeStateBase.Type? = nil,
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
                
                try SemanticError.validateProposedOutcome(
                    expected: implicitlyExpectedMutation,
                    proposed: proposedOutcome
                )
                
                //---
                
                data.removeValue(forKey: feature.name)
                
            case .none:
                
                proposedOutcome = .nothingToRemove(feature: feature)
                
                //---
                
                try SemanticError.validateProposedOutcome(
                    expected: implicitlyExpectedMutation,
                    proposed: proposedOutcome
                )
        }
        
        //---
              
        logHistoryEvent(
            outcome: proposedOutcome
        )
        
        //---
        
        return proposedOutcome
    }
    
    @discardableResult
    mutating
    func removeAll() throws -> [MutationAttemptOutcome] {
        
        try allFeatures
            .map {
                try removeState(forFeature: $0, fromStateType: nil, strict: false)
            }
    }
}

// MARK: - History management

//internal
extension Storage
{
    mutating
    func logHistoryEvent(
        outcome: MutationAttemptOutcome
    ) {
        
        history.append(
            .init(operation: outcome)
        )
    }
    
    /// Clear the history and return it's copy as result.
    mutating
    func resetHistory() -> History
    {
        let result = history
        history.removeAll()
        lastHistoryResetId = UUID().uuidString
        
        //---
        
        return result
    }
}
