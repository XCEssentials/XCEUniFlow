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
    public
    init() {}
    
    //===
    
    typealias Key = String
    
    var data = [Key: FeatureRepresentation]()
}

// MARK: - GET data

public
extension GlobalModel
{
    func state<S: FeatureRepresentation>(ofType _: S.Type) -> S?
    {
        return data[S.feature.name] as? S
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

    func hasState<S: FeatureRepresentation>(ofType _: S.Type) -> Bool
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
    func state(from globalModel: GlobalModel) -> FeatureRepresentation?
    {
        return globalModel.state(forFeature: self)
    }
    
    //===
    
    static
    func state<S>(from globalModel: GlobalModel) -> S? where
        S: FeatureState,
        S.ParentFeature == Self
    {
        return globalModel.state(forFeature: self)
    }

    //===

    static
    func presented(in globalModel: GlobalModel) -> Bool
    {
        return globalModel.hasState(forFeature: self)
    }
}

// MARK: - GET data - from FeatureState

public
extension FeatureState
{
    static
    func from(_ globalModel: GlobalModel) -> Self?
    {
        return globalModel.state(ofType: self)
    }
    
    //===
    
    static
    func presented(in globalModel: GlobalModel) -> Bool
    {
        return globalModel.hasState(ofType: self)
    }
}

// MARK: - GET data -Operators

public
func << <S: FeatureState>(_: S.Type, global: GlobalModel) -> S?
{
    return global.state(ofType: S.self)
}

//===

public
func << <F: Feature>(_: F.Type, global: GlobalModel) -> FeatureRepresentation?
{
    return global.state(forFeature: F.self)
}

//===

public
func >> <F: Feature>(global: GlobalModel, _: F.Type) -> FeatureRepresentation?
{
    return global.state(forFeature: F.self)
}

//===

public
func >> <F, S>(global: GlobalModel, _: F.Type) -> S? where
    S: FeatureState,
    S.ParentFeature == F
{
    return global.state(forFeature: F.self)
}

//===

public
func >> <S: FeatureState>(global: GlobalModel, _: S.Type) -> S?
{
    return global.state(ofType: S.self)
}

// MARK: - SET data

extension GlobalModel
{
    @discardableResult
    func store<S: FeatureRepresentation>(_ state: S) -> GlobalModel
    {
        var result = self
        result.data[S.feature.name] = state

        //---

        return result
    }
}

// MARK: - SET data - from FeatureState

//public
//extension FeatureState
//{
//    @discardableResult
//    func store(in storage: inout GlobalModel) -> Self
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
//func << <S: FeatureState>(global: inout GlobalModel, state: S?)
//{
//    global.store(state)
//}

// MARK: - REMOVE data

extension GlobalModel
{
    @discardableResult
    func removeState<S: FeatureState>(ofType _: S.Type) -> GlobalModel
    {
        guard
            hasState(ofType: S.self)
        else
        {
            return self
        }
        
        //---
        
        var result = self
        result.data[S.ParentFeature.name] = nil
        
        //---
        
        return result
    }

    @discardableResult
    func removeRepresentation<F: Feature>(ofFeature _: F.Type) -> GlobalModel
    {
        guard
            hasState(forFeature: F.self)
        else
        {
            return self
        }

        //---

        var result = self
        result.data[F.name] = nil

        //---

        return result
    }
}

// MARK: - REMOVE data - from Feature

//public
//extension Feature
//{
//    @discardableResult
//    static
//    func remove(from storage: inout GlobalModel) -> Self.Type
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
//    func remove(from storage: inout GlobalModel) -> Self
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
//    func remove(from storage: inout GlobalModel) -> Self.Type
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
//func /< <F: Feature>(global: inout GlobalModel, _: F.Type)
//{
//    global.removeRepresentation(ofFeature: F.self)
//}
