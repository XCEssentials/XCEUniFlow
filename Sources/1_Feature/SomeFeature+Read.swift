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
extension SomeFeature
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
    
    func ensureCurrentStateIs(_ desiredState: SomeStateBase.Type) throws
    {
        try ensureCurrentState(isInTheList: [desiredState])
    }
    
    func ensureCurrentState(isOneOf whitelist: SomeStateBase.Type...) throws
    {
        try ensureCurrentState(isInTheList: whitelist)
    }
    
    func ensureCurrentState(isInTheList whitelist: [SomeStateBase.Type]) throws
    {
        let typeOfCurrentState = try dispatcher
            .fetchState(
                forFeature: Self.self
            )
            ./ { type(of: $0) }
        
        guard
            whitelist.contains(where: { $0 == typeOfCurrentState })
        else
        {
            throw CurrentStateCheckError.currentStateIsNotInTheList(whitelist)
        }
    }
    
    /// Allows to fetch any state of any feature from `dispatcher`.
    @discardableResult
    func fetchState<S: SomeState>(
        _: S.Type = S.self
    ) throws -> S {
        
        try dispatcher.fetchState(
            ofType: S.self
        )
    }
}
