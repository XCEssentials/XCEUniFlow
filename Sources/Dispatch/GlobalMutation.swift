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

//===

enum FeatureMutationKind: String
{
    case addition, update, removal
}

protocol GlobalMutationExt: GlobalMutation
{
    /**
     Feature to which this mutation is related.
     */
    static
    var feature: Feature.Type { get }
    
    static
    var kind: FeatureMutationKind { get }
    
    var apply: (GlobalModel) -> GlobalModel { get }
}

// MARK: - Transition

extension Transition
{
    public
    static
    var feature: Feature.Type { return F.self }
    
    //===
    
    // let someOldAppState = TransitionOf<M.App>(diff)?.oldState
    // let someNewAppState = TransitionOf<M.App>(diff)?.newState
    
    public
    init?(_ diff: GlobalMutation)
    {
        guard
            let mutation = diff as? Transition<F>
        else
        {
            return nil
        }
        
        //---
        
        self = mutation
    }
}

//===

extension TransitionFrom
{
    // let appRunning = TransitionFrom<M.App.Running>(diff)?.oldState
    
    public
    init?(_ diff: GlobalMutation)
    {
        guard
            let mutation = diff as? Transition<S.ParentFeature>,
            let oldState = mutation.oldState as? S
        else
        {
            return nil
        }
        
        //---
        
        self = TransitionFrom(oldState: oldState)
    }
}

//===

extension TransitionInto
{
    // let appRunning = TransitionInto<M.App.Running>(diff)?.newState
    
    public
    init?(_ diff: GlobalMutation)
    {
        guard
            let mutation = diff as? Transition<S.ParentFeature>,
            let newState = mutation.newState as? S
        else
        {
            return nil
        }
        
        //---
        
        self = TransitionInto(newState: newState)
    }
}

//===

#if swift(>=3.2)
    
extension TransitionBetween
{
    // let appPreparing = TransitionBetween<M.App.Preparing, M.App.Running>(diff)?.oldState
    // let appRunning = TransitionBetween<M.App.Preparing, M.App.Running>(diff)?.newState
    
    public
    init?(_ diff: GlobalMutation)
    {
        guard
            let mutation = diff as? Transition<From.ParentFeature>,
            let oldState = mutation.oldState as? From,
            let newState = mutation.newState as? Into
        else
        {
            return nil
        }
        
        //---
        
        self = TransitionBetween(oldState: oldState, newState: newState)
    }
}
    
#endif
