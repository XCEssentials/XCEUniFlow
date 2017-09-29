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
    struct Between<From: State, Into: State>: ActionKind where
        From.Parent == F,
        Into.Parent == F
    {
        public
        let oldState: From
        
        public
        let newState: Into
        
        //===
        
        init(_ oldState: From, _ newState: Into)
        {
            self.oldState = oldState
            self.newState = newState
        }
        
        //===
        
        /**
         Usage:
         
         ```swift
         let appPreparing = TransitionBetween<M.App.Preparing, M.App.Running>(diff)?.oldState
         let appRunning = TransitionBetween<M.App.Preparing, M.App.Running>(diff)?.newState
         ```
         */
        public
        init?(_ mutation: GlobalMutation?)
        {
            guard
                let mutation = mutation as? Transition<From.Parent>,
                let oldState = mutation.oldState as? From,
                let newState = mutation.newState as? Into
            else
            {
                return nil
            }
            
            //---
            
            self = Transition<F>.Between(oldState, newState)
        }
    }
}

//===

#if swift(>=3.2)
    
public
typealias TransitionBetween<From: State, Into: State> =
    Transition<From.Parent>.Between<From, Into>
    where
    From.Parent == Into.Parent
    
#endif

// MARK: - Action builders

public
extension Transition.Between where Into: AutoInitializable
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
                
            try Require("\(F.name) is in \(From.self) state").isNotNil(
                
                model >> From.self
            )
            
            //---
            
            let newState = Into.init()
            
            //---
            
            completion?(submit)
            
            //---
            
            return Transition(from: oldState, into: newState)
        }
    }
}

//===

public
extension Transition.Between
{
    static
    func via(
        scope: String = #file,
        context: String = #function,
        body: @escaping (From, Become<Into>, @escaping SubmitAction) throws -> Void
        ) -> Action
    {
        return Action(scope, context, self) { model, submit in
            
            let oldState =
                
            try Require("\(F.name) is in \(From.self) state").isNotNil(
                
                model >> From.self
            )
            
            //---
            
            var newState: Into!
            
            //---
            
            try body(oldState, { newState = $0 }, submit)
            
            //---
            
            try Require("New state for \(F.name) is set").isNotNil(
                
                newState
            )
            
            //---
            
            return Transition(from: oldState, into: newState)
        }
    }
}
