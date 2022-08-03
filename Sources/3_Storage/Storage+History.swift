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
extension Storage
{
    typealias History = [HistoryElement]
    
    struct HistoryElement
    {
        public
        let timestamp: Date = .init()
    
        public
        let outcome: MutationAttemptOutcome
    }
}

//---

public
extension Storage.HistoryElement
{
    var feature: SomeFeature.Type
    {
        switch self.outcome
        {
            case
                .initialization(let state),
                .actualization(let state, _),
                .transition(let state, _),
                .deinitialization(let state):
                
                return type(of: state).feature
                
            case .nothingToRemove(let feature):
                return feature
        }
    }
}

// MARK: - AnyMutation helpers

public
extension Storage.HistoryElement
{
    struct AnyMutationOutcome
    {
        public
        let timestamp: Date
    
        public
        let feature: SomeFeature.Type
        
        public
        let oldState: SomeStateBase?
        
        public
        let newState: SomeStateBase?
    }
    
    var asAnyMutation: AnyMutationOutcome?
    {
        switch self.outcome
        {
            case let .initialization(newState):
                
                return .init(
                    timestamp: self.timestamp,
                    feature: type(of: newState).feature,
                    oldState: nil,
                    newState: newState
                )
                
            case let .actualization(oldState, newState),
                let .transition(oldState, newState):
                
                return .init(
                    timestamp: self.timestamp,
                    feature: type(of: oldState).feature,
                    oldState: oldState,
                    newState: newState
                )
                
            case let .deinitialization(oldState):
                
                return .init(
                    timestamp: self.timestamp,
                    feature: type(of: oldState).feature,
                    oldState: oldState,
                    newState: nil
                )
                
            default:
                return nil
        }
    }
    
    var isAnyMutation: Bool
    {
        asAnyMutation != nil
    }
}

// MARK: - Initialization helpers

public
extension Storage.HistoryElement
{
    struct InitializationOutcome
    {
        public
        let timestamp: Date
    
        public
        let feature: SomeFeature.Type
        
        public
        let newState: SomeStateBase
    }
    
    var asInitialization: InitializationOutcome?
    {
        switch self.outcome
        {
            case let .initialization(newState):
                
                return .init(
                    timestamp: self.timestamp,
                    feature: type(of: newState).feature,
                    newState: newState
                )
                
            default:
                return nil
        }
    }
    
    var isInitialization: Bool
    {
        asInitialization != nil
    }
}

// MARK: - Setting helpers

public
extension Storage.HistoryElement
{
    /// Operation that results with given feature being present in the storage.
    struct SettingOutcome
    {
        public
        let timestamp: Date
    
        public
        let feature: SomeFeature.Type
        
        public
        let newState: SomeStateBase
    }
    
    /// Operation that results with given key being present in the storage.
    var asSetting: SettingOutcome?
    {
        switch self.outcome
        {
            case
                let .initialization(newState),
                let .actualization(_, newState),
                let .transition(_, newState):
                
                return .init(
                    timestamp: self.timestamp,
                    feature: type(of: newState).feature,
                    newState: newState
                )
                
            default:
                return nil
        }
    }
    
    /// Operation that results with given key being present in the storage.
    var isSetting: Bool
    {
        asSetting != nil
    }
}

// MARK: - Update helpers

public
extension Storage.HistoryElement
{
    /// Operation that has both old and new states.
    struct UpdateOutcome
    {
        public
        let timestamp: Date
    
        public
        let feature: SomeFeature.Type
        
        public
        let oldState: SomeStateBase
        
        public
        let newState: SomeStateBase
    }
    
    /// Operation that has both old and new states.
    var asUpdate: UpdateOutcome?
    {
        switch self.outcome
        {
            case
                let .actualization(oldState, newState),
                let .transition(oldState, newState):
                
                return .init(
                    timestamp: self.timestamp,
                    feature: type(of: oldState).feature,
                    oldState: oldState,
                    newState: newState
                )
                
            default:
                return nil
        }
    }
    
    /// Operation that has both old and new states.
    var isUpdate: Bool
    {
        asUpdate != nil
    }
}

// MARK: - Actualization helpers

public
extension Storage.HistoryElement
{
    struct ActualizationOutcome
    {
        public
        let timestamp: Date
    
        public
        let feature: SomeFeature.Type
        
        public
        let oldState: SomeStateBase
        
        public
        let newState: SomeStateBase
    }
    
    var asActualization: ActualizationOutcome?
    {
        switch self.outcome
        {
            case let .actualization(oldState, newState):
                
                return .init(
                    timestamp: self.timestamp,
                    feature: type(of: oldState).feature,
                    oldState: oldState,
                    newState: newState
                )
                
            default:
                return nil
        }
    }
    
    var isActualization: Bool
    {
        asActualization != nil
    }
}

// MARK: - Transition helpers

public
extension Storage.HistoryElement
{
    struct TransitionOutcome
    {
        public
        let timestamp: Date
    
        public
        let feature: SomeFeature.Type
        
        public
        let oldState: SomeStateBase
        
        public
        let newState: SomeStateBase
    }
    
    var asTransition: TransitionOutcome?
    {
        switch self.outcome
        {
            case let .transition(oldState, newState):
                
                return .init(
                    timestamp: self.timestamp,
                    feature: type(of: oldState).feature,
                    oldState: oldState,
                    newState: newState
                )
                
            default:
                return nil
        }
    }
    
    var isTransition: Bool
    {
        asTransition != nil
    }
}

// MARK: - Deinitialization helpers

public
extension Storage.HistoryElement
{
    struct DeinitializationOutcome
    {
        public
        let timestamp: Date
    
        public
        let feature: SomeFeature.Type
        
        public
        let oldState: SomeStateBase
    }
    
    var asDeinitialization: DeinitializationOutcome?
    {
        switch self.outcome
        {
            case let .deinitialization(oldState):
                
                return .init(
                    timestamp: self.timestamp,
                    feature: type(of: oldState).feature,
                    oldState: oldState
                )
                
            default:
                return nil
        }
    }
    
    var isDeinitialization: Bool
    {
        asDeinitialization != nil
    }
}

// MARK: - BlankRemoval helpers

public
extension Storage.HistoryElement
{
    struct BlankRemovalOutcome
    {
        public
        let timestamp: Date
    
        public
        let feature: SomeFeature.Type
    }
    
    var asBlankRemovalOutcome: BlankRemovalOutcome?
    {
        switch self.outcome
        {
            case let .nothingToRemove(feature):
                
                return .init(
                    timestamp: self.timestamp,
                    feature: feature
                )
                
            default:
                return nil
        }
    }
    
    var isBlankRemoval: Bool
    {
        asBlankRemovalOutcome != nil
    }
}
