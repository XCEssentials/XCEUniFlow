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
enum SemanticCheckError: Error
{
    case alreadyInitialized(Feature.Type)
    
    case notInitializedYet(Feature.Type)
    
    case unexpectedCurrentState(
        expected: [any FeatureState.Type],
        actual: any FeatureState.Type
    )
}

//---

public
extension TransactionContext
{
    func ensureAwaitingInitialization<F: Feature>(_: F.Type) throws
    {
        guard
            !storage.hasFeature(F.self)
        else
        {
            throw SemanticCheckError.alreadyInitialized(F.self)
        }
    }
    
    func ensureAlreadyInitialized<F: Feature>(_: F.Type) throws
    {
        guard
            storage.hasFeature(F.self)
        else
        {
            throw SemanticCheckError.notInitializedYet(F.self)
        }
    }
    
    func fetchCurrentState<F: Feature>(of _: F.Type) -> (any FeatureState)?
    {
        storage[F.self]
    }
    
    @discardableResult
    func ensureCurrentState<F: Feature>(
        of _: F.Type,
        isInTheList whitelist: [any FeatureState.Type]
    ) throws -> any FeatureState {
        
        guard
            let state = fetchCurrentState(of: F.self)
        else
        {
            throw SemanticCheckError.notInitializedYet(F.self)
        }
        
        let typeOfCurrentState = type(of: state)
        
        guard
            whitelist.contains(where: { $0 == typeOfCurrentState })
        else
        {
            throw SemanticCheckError
                .unexpectedCurrentState(
                    expected: whitelist,
                    actual: typeOfCurrentState
                )
        }
        
        return state
    }
    
    @discardableResult
    func ensureCurrentState<S: FeatureState>(
        is _: S.Type = S.self
    ) throws -> S {
        
        let someState = try ensureCurrentState(
            of: S.ParentFeature.self,
            isInTheList: [S.self]
        )
        
        guard
            let state = someState as? S
        else
        {
            throw SemanticCheckError
                .unexpectedCurrentState(
                    expected: [S.self],
                    actual: type(of: someState).self
                )
        }
        
        return state
    }
    
    @discardableResult
    func ensureCurrentState<F: Feature>(
        of _: F.Type,
        isOneOf whitelist: any FeatureState.Type...
    ) throws -> any FeatureState {
        
        try ensureCurrentState(
            of: F.self,
            isInTheList: whitelist
        )
    }
    
    func ensureIsSet<R: FeatureState, V>(
        _ keyPath: KeyPath<R, V>
    ) throws -> V {
        
        try ensureCurrentState(is: R.state)[keyPath: keyPath]
    }
}
