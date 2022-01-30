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
struct ByTypeStorage
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
extension ByTypeStorage
{
    enum ReadDataError: Error
    {
        case keyNotFound(
            SomeStateful.Type
        )
        
        case valueTypeMismatch(
            key: SomeStateful.Type,
            expected: SomeStateBase.Type,
            actual: SomeStateBase
        )
    }
}

// MARK: - GET data

public
extension ByTypeStorage
{
    var allValues: [SomeStateBase]
    {
        .init(data.values)
    }
    
    var allKeys: [SomeStateful.Type]
    {
        allValues
            .map {
                type(of: $0).feature
            }
    }
    
    func fetch(valueForKey keyType: SomeStateful.Type) throws -> SomeStateBase
    {
        if
            let result = data[keyType.name]
        {
            return result
        }
        else
        {
            throw ReadDataError.keyNotFound(keyType)
        }
    }
    
    func fetch<V: SomeState>(valueOfType _: V.Type = V.self) throws -> V
    {
        let someResult = try fetch(valueForKey: V.Feature.self)
        
        //---
        
        if
            let result = someResult as? V
        {
            return result
        }
        else
        {
            throw ReadDataError.valueTypeMismatch(
                key: V.Feature.self,
                expected: V.self,
                actual: someResult
            )
        }
    }
}

// MARK: - SET data

public
extension ByTypeStorage
{
    @discardableResult
    mutating
    func store<V: SomeState>(
        _ value: V,
        expectedMutation: ExpectedMutation = .auto
    ) throws -> MutationAttemptOutcome {
        
        let outcome: MutationAttemptOutcome
        
        //---
        
        switch (data[V.Feature.name], value)
        {
            case (.none, let newValue):
                
                outcome = .initialization(key: V.Feature.self, newValue: newValue)
                
                //---
                
                try expectedMutation.validateProposedOutcome(outcome)
                
                //---
                
                data[V.Feature.name] = newValue
                
            //---
                
            case (.some(let oldValue), let newValue):
                
                if
                    type(of: oldValue) == type(of: newValue)
                {
                    outcome = .actualization(key: V.Feature.self, oldValue: oldValue, newValue: newValue)
                }
                else
                {
                    outcome = .transition(key: V.Feature.self, oldValue: oldValue, newValue: newValue)
                }
                
                //---
                
                try expectedMutation.validateProposedOutcome(outcome)
                
                //---
                
                data[V.Feature.name] = newValue
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
extension ByTypeStorage
{
    @discardableResult
    mutating
    func removeValue(
        forKey keyType: SomeStateful.Type,
        fromValueType: SomeStateBase.Type? = nil,
        strict: Bool = true
    ) throws -> MutationAttemptOutcome {
        
        let implicitlyExpectedMutation: ExpectedMutation = .deinitialization(
            fromValueType: fromValueType,
            strict: strict
        )
        
        let outcome: MutationAttemptOutcome
        
        //---
        
        switch data[keyType.name]
        {
            case .some(let oldValue):
                
                outcome = .deinitialization(key: keyType, oldValue: oldValue)
                
                //---
                
                try implicitlyExpectedMutation.validateProposedOutcome(outcome)
                
                //---
                
                data.removeValue(forKey: keyType.name)
                
            case .none:
                
                outcome = .nothingToRemove(key: keyType)
                
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
        
        try allKeys
            .map {
                try removeValue(forKey: $0, fromValueType: nil, strict: false)
            }
    }
}

// MARK: - History management

//internal
extension ByTypeStorage
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
