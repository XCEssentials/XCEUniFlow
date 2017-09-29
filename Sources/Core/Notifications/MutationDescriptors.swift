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

/**
 Special type for unified bindings look that only will create binding if mutation is 'nil'.
 */
public
struct NoMutation: MutationConvertible
{
    public
    init?(_ mutation: GlobalMutation?)
    {
        if
            mutation == nil
        {
            // okay
        }
        else
        {
            return nil
        }
    }
}

//===

public
struct AnyMutation: MutationConvertible
{
    public
    let relatedToFeature: Feature.Type

    //===

    public
    init?(_ mutation: GlobalMutation?)
    {
        if
            let feature = (mutation as? GlobalMutationExt)?.relatedToFeature
        {
            self.relatedToFeature = feature
        }
        else
        {
            return nil
        }
    }
}

//===

public
struct AnyMutationOf<F: Feature>: MutationConvertible
{
    public
    init?(_ mutation: GlobalMutation?)
    {
        if
            let feature = (mutation as? GlobalMutationExt)?.relatedToFeature,
            feature == F.self
        {
            // okay
        }
        else
        {
            return nil
        }
    }
}

//===

/**
 Special kind of mutation descriptor that will be resolved in a non-nil value from any mutation except deinitialization, i.e. any mutation that adds or updates the feature in global model.
 */
public
struct AnySettingOf<F: Feature>: MutationConvertible
{
    public
    let featureState: SomeState

    //===

    public
    init?(_ mutation: GlobalMutation?)
    {
        if
            let setting = mutation as? FeatureSetting,
            setting.relatedToFeature == F.self
        {
            self.featureState = setting.newState
        }
        else
        {
            return nil
        }
    }
}

//===

/**
 Special kind of mutation descriptor that will be resolved in a non-nil value from any mutation except initialization or deinitialization, i.e. any mutation that updates the feature in global model.
 */
public
struct AnyUpdateOf<F: Feature>: MutationConvertible
{
    public
    let featureState: SomeState

    //===

    public
    init?(_ mutation: GlobalMutation?)
    {
        if
            let update = mutation as? FeatureUpdate,
            update.relatedToFeature == F.self
        {
            self.featureState = update.newState
        }
        else
        {
            return nil
        }
    }
}
