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

import XCEPipeline

/// These errors are being thrown by special helpers
/// that check if the feature is initialized or not
/// within given `Dispatcher`.
public
enum InitializationStatusCheckError: Error
{
    case alreadyInitialized(SomeFeature.Type)
    case notInitializedYet(SomeFeature.Type)
}

public
enum CurrentStateCheckError: Error
{
    case currentStateIsNotInTheList([SomeStateBase.Type])
}

//---

public
extension FeatureBase
{
    /// Throws `InitializationStatusCheckError` if `self` is
    /// already initialized within `dispatcher`.
    func ensureAwaitingInitialization() throws
    {
        guard
            !dispatcher.hasFeatureInitialized(Self.self)
        else
        {
            throw InitializationStatusCheckError.alreadyInitialized(Self.self)
        }
    }
    
    /// Throws `InitializationStatusCheckError` if `self` is
    /// NOT initialized yet within `dispatcher`.
    func ensureAlreadyInitialized() throws
    {
        guard
            dispatcher.hasFeatureInitialized(Self.self)
        else
        {
            throw InitializationStatusCheckError.notInitializedYet(Self.self)
        }
    }
    
    @discardableResult
    func ensureCurrentStateIs(_ desiredState: SomeStateBase.Type) throws -> SomeStateBase
    {
        try ensureCurrentState(isInTheList: [desiredState])
    }
    
    @discardableResult
    func ensureCurrentState(isOneOf whitelist: SomeStateBase.Type...) throws -> SomeStateBase
    {
        try ensureCurrentState(isInTheList: whitelist)
    }
    
    @discardableResult
    func ensureCurrentState(isInTheList whitelist: [SomeStateBase.Type]) throws -> SomeStateBase
    {
        let state = try fetchCurrentState()
        let typeOfCurrentState = type(of: state)
        
        guard
            whitelist.contains(where: { $0 == typeOfCurrentState })
        else
        {
            throw CurrentStateCheckError.currentStateIsNotInTheList(whitelist)
        }
        
        return state
    }
    
    /// Fetch state `S` of any feature from `dispatcher`.
    func fetchState<S: SomeState>(
        _: S.Type = S.self
    ) throws -> S {
        
        try dispatcher.fetchState(
            ofType: S.self
        )
    }
    
    /// Fetch any state of feature `F` from `dispatcher`.
    func fetchState<F: SomeFeature>(
        for _: F.Type
    ) throws -> SomeStateBase {
        
        try dispatcher.fetchState(
            forFeature: F.self
        )
    }
    
    /// Fetch current state of `Self` from `dispatcher`.
    func fetchCurrentState() throws -> SomeStateBase {
        
        try dispatcher.fetchState(
            forFeature: Self.self
        )
    }
}
