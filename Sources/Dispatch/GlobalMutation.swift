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
protocol GlobalMutation { }

// MARK: - GlobalMutationExt

protocol GlobalMutationExt: GlobalMutation
{
    var relatedToFeature: Feature.Type { get }
    
    var apply: (GlobalModel) -> GlobalModel { get }
}

//===

protocol FeatureSetting: GlobalMutationExt
{
    var newState: SomeState { get }
}

extension FeatureSetting
{
    var relatedToFeature: Feature.Type
    {
        return type(of: newState).feature
    }
    
    var apply: (GlobalModel) -> GlobalModel
    {
        return { $0.store(self.newState) }
    }
}

//===

protocol FeatureAddition: FeatureSetting {}

//===

protocol FeatureUpdate: FeatureSetting {}

//===

protocol FeatureRemoval: GlobalMutationExt { }

extension FeatureRemoval
{
    var apply: (GlobalModel) -> GlobalModel
    {
        return { $0.removeRepresentation(of: self.relatedToFeature) }
    }
}

// MARK: - MutationConvertible

public
protocol MutationConvertible
{
    init?(_ mutation: GlobalMutation?)
}

//===

public
extension MutationConvertible
{
    init?(_ mutation: GlobalMutation?)
    {
        return nil
    }
}
