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

import XCERequirement

//===

public
extension Transition
{
    struct Into<S: FeatureState> where S.ParentFeature == F
    {
        public
        let newState: S
        
        //===
        
        init(_ newState: S)
        {
            self.newState = newState
        }
        
        //===
        
        /**
         Usage:
         
         ```swift
         let appRunning = TransitionInto<M.App.Running>(diff)?.newState
         ```
         */
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
            
            self = TransitionInto(newState)
        }
    }
}

//===

public
typealias TransitionInto<S: FeatureState> = Transition<S.ParentFeature>.Into<S>

//===

public
extension Transition.Into where S: SimpleState
{
    static
    func automatically(
        scope: String = #file,
        context: String = #function,
        completion: ((@escaping SubmitAction) -> Void)? = nil
        ) -> Action
    {
        return Action(scope, context, self) { model, submit in
            
            let oldState =
                
            try Require("\(F.name) is presented").isNotNil(
                
                model >> F.self
            )
            
            //---
            
            let newState = S.init()
            
            //---
            
            completion?(submit)
            
            //---
            
            return Transition(from: oldState, into: newState)
        }
    }
}

//===

public
extension Transition.Into
{
    static
    func via(
        scope: String = #file,
        context: String = #function,
        body: @escaping (GlobalModel, Become<S>, @escaping SubmitAction) throws -> Void
        ) -> Action
    {
        return Action(scope, context, self) { model, submit in
            
            let oldState =
                
            try Require("\(F.name) is presented").isNotNil(
                
                model >> F.self
            )
            
            //---
            
            var newState: S!
            
            //---
            
            try body(model, { newState = $0 }, submit)
            
            //---
            
            try Require("New state for \(F.name) is set").isNotNil(
                
                newState
            )
            
            //---
            
            return Transition(from: oldState, into: newState)
        }
    }
}
