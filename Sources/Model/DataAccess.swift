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

// MARK: - GET data

public
extension NewModel
{
    func state<S: FeatureState>(ofType _: S.Type) -> S?
    {
        return data[S.ParentFeature.name] as? S
    }

    func state<F: Feature>(forFeature _: F.Type) -> FeatureRepresentation?
    {
        return data[F.name]
    }

    func state<F, S>(forFeature _: F.Type) -> S? where
        S: FeatureState,
        S.ParentFeature == F
    {
        return data[F.name] as? S
    }

    //===

    func hasState<S: FeatureState>(ofType _: S.Type) -> Bool
    {
        return state(ofType: S.self) != nil
    }

    func hasState<F: Feature>(forFeature _: F.Type) -> Bool
    {
        return state(forFeature: F.self) != nil
    }
}

// MARK: - GET data - from Feature

public
extension Feature
{
    static
    func state(from globalModel: NewModel) -> FeatureRepresentation?
    {
        return globalModel.state(forFeature: self)
    }
    
    //===
    
    static
    func state<S>(from globalModel: NewModel) -> S? where
        S: FeatureState,
        S.ParentFeature == Self
    {
        return globalModel.state(forFeature: self)
    }

    //===

    static
    func presented(in globalModel: NewModel) -> Bool
    {
        return globalModel.hasState(forFeature: self)
    }
}

// MARK: - GET data - from FeatureState

public
extension FeatureState
{
    static
    func from(_ globalModel: NewModel) -> Self?
    {
        return globalModel.state(ofType: self)
    }
    
    //===
    
    static
    func presented(in globalModel: NewModel) -> Bool
    {
        return globalModel.hasState(ofType: self)
    }
}

// MARK: - GET data -Operators

public
func << <S: FeatureState>(_: S.Type, global: NewModel) -> S?
{
    return global.state(ofType: S.self)
}

//===

public
func << <F: Feature>(_: F.Type, global: NewModel) -> FeatureRepresentation?
{
    return global.state(forFeature: F.self)
}

//===

public
func >> <F: Feature>(global: NewModel, _: F.Type) -> FeatureRepresentation?
{
    return global.state(forFeature: F.self)
}

//===

public
func >> <F, S>(global: NewModel, _: F.Type) -> S? where
    S: FeatureState,
    S.ParentFeature == F
{
    return global.state(forFeature: F.self)
}

//===

public
func >> <S: FeatureState>(global: NewModel, _: S.Type) -> S?
{
    return global.state(ofType: S.self)
}

// MARK: - Mutation metadata

extension NewModel
{
    enum MutationDiff
    {
        case addition(Feature.Type)
        case update(Feature.Type)
        case removal(Feature.Type)
    }
    
    typealias MutationResult = (storage: NewModel, diff: MutationDiff)
}

// MARK: - SET data

extension NewModel
{
    @discardableResult
    func store<S: FeatureState>(_ state: S?) -> MutationResult
    {
        let diff: MutationDiff

        if
            hasState(ofType: S.self)
        {
            diff = .update(S.ParentFeature.self)
        }
        else
        {
            diff = .addition(S.ParentFeature.self)
        }

        //---

        var storage = self

        storage.data[S.ParentFeature.name] = state

        //---

        return (storage, diff)
    }
}

// MARK: - SET data - from FeatureState

//public
//extension FeatureState
//{
//    @discardableResult
//    func store(in storage: inout NewModel) -> Self
//    {
//        storage.store(self)
//
//        //---
//
//        return self
//    }
//}

// MARK: - SET data - Operators

//public
//func << <S: FeatureState>(global: inout NewModel, state: S?)
//{
//    global.store(state)
//}

// MARK: - REMOVE data

extension NewModel
{
    @discardableResult
    func removeState<S: FeatureState>(ofType _: S.Type) -> MutationResult?
    {
        guard
            hasState(ofType: S.self)
        else
        {
            return nil
        }
        
        //---
        
        let diff: MutationDiff = .removal(S.ParentFeature.self)
        
        //---
        
        var storage = self
        
        storage.data[S.ParentFeature.name] = nil
        
        //---
        
        return (storage, diff)
    }

    @discardableResult
    func removeRepresentation<F: Feature>(ofFeature _: F.Type) -> MutationResult?
    {
        guard
            hasState(forFeature: F.self)
        else
        {
            return nil
        }

        //---

        let diff: MutationDiff = .removal(F.self)

        //---

        var storage = self

        storage.data[F.name] = nil

        //---

        return (storage, diff)
    }
}

// MARK: - REMOVE data - from Feature

//public
//extension Feature
//{
//    @discardableResult
//    static
//    func remove(from storage: inout NewModel) -> Self.Type
//    {
//        storage.removeRepresentation(ofFeature: self)
//
//        //---
//
//        return self
//    }
//}

// MARK: - REMOVE data - from FeatureState

//public
//extension FeatureState
//{
//    @discardableResult
//    func remove(from storage: inout NewModel) -> Self
//    {
//        storage.removeState(ofType: type(of: self))
//
//        //---
//
//        return self
//    }
//
//    @discardableResult
//    static
//    func remove(from storage: inout NewModel) -> Self.Type
//    {
//        storage.removeState(ofType: self)
//
//        //---
//
//        return self
//    }
//}

// MARK: Operators - REMOVE

//public
//func /< <F: Feature>(global: inout NewModel, _: F.Type)
//{
//    global.removeRepresentation(ofFeature: F.self)
//}

