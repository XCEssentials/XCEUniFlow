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
struct GlobalModel
{
    init() {}
    
    //===
    
    typealias Key = String
    
    var data = [Key: SomeState]()
}

// MARK: - Errors

public
protocol GlobalModelError: Error { }

public
extension GlobalModel
{
    struct NoSuchFeature: GlobalModelError
    {
        let feature: Feature.Type
    }
    
    struct NoSuchState: GlobalModelError
    {
        let state: SomeState.Type
        
        var feature: Feature.Type
        {
            return state.feature
        }
    }
}

// MARK: - GET data

public
extension GlobalModel
{
    func state<S: SomeState>(ofType _: S.Type) throws -> S
    {
        guard
            let result = data[S.feature.name] as? S
        else
        {
            throw NoSuchState(state: S.self)
        }
        
        //---
        
        return result
    }

    //===

    func state(for feature: Feature.Type) throws -> SomeState
    {
        guard
            let result = data[feature.name]
        else
        {
            throw NoSuchFeature(feature: feature)
        }
        
        //---
        
        return result
    }

    //===

    func state<F, S>(for _: F.Type) throws -> S
        where
        S: State,
        S.Parent == F
    {
        guard
            let result = data[F.name] as? S
        else
        {
            throw NoSuchState(state: S.self)
        }
        
        //---
        
        return result
    }

    //===

    func hasState<S: SomeState>(ofType _: S.Type) -> Bool
    {
        return (try? state(ofType: S.self)) != nil
    }

    //===

    func hasState(for feature: Feature.Type) -> Bool
    {
        return (try? state(for: feature)) != nil
    }
}

// MARK: - GET data - from Feature

public
extension Feature
{
    static
    func state(from globalModel: GlobalModel) throws -> SomeState
    {
        return try globalModel.state(for: self)
    }
    
    //===
    
    static
    func state<S>(from globalModel: GlobalModel) throws -> S?
        where
        S: State,
        S.Parent == Self
    {
        return try globalModel.state(for: self)
    }

    //===

    static
    func presented(in globalModel: GlobalModel) -> Bool
    {
        return globalModel.hasState(for: self)
    }
}

// MARK: - GET data - from State

public
extension State
{
    static
    func from(_ globalModel: GlobalModel) throws -> Self
    {
        return try globalModel.state(ofType: self)
    }
    
    //===
    
    static
    func presented(in globalModel: GlobalModel) -> Bool
    {
        return globalModel.hasState(ofType: self)
    }
}

// MARK: - SET data

extension GlobalModel
{
    @discardableResult
    func store(_ state: SomeState) -> GlobalModel
    {
        var result = self
        result.data[type(of: state).feature.name] = state

        //---

        return result
    }
}

// MARK: - REMOVE data

extension GlobalModel
{
    @discardableResult
    func removeRepresentation(of feature: Feature.Type) -> GlobalModel
    {
        guard
            hasState(for: feature)
        else
        {
            return self
        }

        //---

        var result = self
        result.data[feature.name] = nil

        //---

        return result
    }
}
