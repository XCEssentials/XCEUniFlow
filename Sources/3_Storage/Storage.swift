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
    
    func fetchState<S: SomeState>(ofType _: S.Type = S.self) throws -> S
    {
        let someState = try fetchState(forFeature: S.Feature.self)
        
        //---
        
        if
            let result = someState as? S
        {
            return result
        }
        else
        {
            throw ReadDataError.stateTypeMismatch(
                feature: S.Feature.self,
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
    func store<S: SomeState>(
        _ state: S,
        expectedMutation: ExpectedMutation = .auto
    ) throws -> MutationAttemptOutcome {
        
        let outcome: MutationAttemptOutcome
        
        //---
        
        switch (data[type(of: state).feature.name], state)
        {
            case (.none, let newState):
                
                outcome = .initialization(newState: newState)
                
                //---
                
                try expectedMutation.validateProposedOutcome(outcome)
                
                //---
                
                data[S.Feature.name] = newState
                
            //---
                
            case (.some(let oldState), let newState):
                
                if
                    type(of: oldState) == type(of: newState)
                {
                    outcome = .actualization(oldState: oldState, newState: newState)
                }
                else
                {
                    outcome = .transition(oldState: oldState, newState: newState)
                }
                
                //---
                
                try expectedMutation.validateProposedOutcome(outcome)
                
                //---
                
                data[S.Feature.name] = newState
        }
        
        //---
              
        logHistoryEvent(
            outcome: outcome
        )
        
        //---
        
        return outcome
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
        
        let outcome: MutationAttemptOutcome
        
        //---
        
        switch data[feature.name]
        {
            case .some(let oldState):
                
                outcome = .deinitialization(oldState: oldState)
                
                //---
                
                try implicitlyExpectedMutation.validateProposedOutcome(outcome)
                
                //---
                
                data.removeValue(forKey: feature.name)
                
            case .none:
                
                outcome = .nothingToRemove(feature: feature)
                
                //---
                
                try implicitlyExpectedMutation.validateProposedOutcome(outcome)
        }
        
        //---
              
        logHistoryEvent(
            outcome: outcome
        )
        
        //---
        
        return outcome
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
            .init(outcome: outcome)
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
