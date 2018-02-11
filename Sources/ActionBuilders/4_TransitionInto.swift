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
    struct Into<S: State>: ActionKind where S.Parent == F
    {
        public
        enum SameStateStrategy
        {
            /**
             'ok' means "it's okay to override in case old/current state
             is the same as the new/target one". NOTE, that old/new states are
             compared by state type/name, not via 'Equatable' protocol.
             */
            case ok //swiftlint:disable:this identifier_name

            /**
             'no' means "do NOT override in case old/current state
             is the same as the new/target one". NOTE, that old/new states are
             compared by state type/name, not via 'Equatable' protocol.
             */
            case no //swiftlint:disable:this identifier_name
        }

        //===

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
        init?(_ mutation: GlobalMutation?)
        {
            guard
                let mutation = mutation as? Transition<S.Parent>,
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
typealias TransitionInto<S: State> = Transition<S.Parent>.Into<S>

// MARK: - Action builders

public
extension Transition.Into where S: AutoInitializable
{
    static
    func automatically(
        scope: String = #file,
        context: String = #function,
        same: SameStateStrategy,
        body: ((GlobalModel, SomeState, S, @escaping SubmitAction) throws -> Void)? = nil
        ) -> Action
    {
        return Action(scope, context, self)
        {
            globalModel, submit in

            //---

            let oldState =
                
            try Require("\(F.name) is presented").isNotNil(
                
                globalModel >> F.self
            )

            //---

            try Require("Reset strategy satisfied").isFalse(

                (same == .no) && (oldState is S)
            )

            //---
            
            let newState = S()
            
            //---
            
            try body?(globalModel, oldState, newState, submit)
            
            //---
            
            return Transition(from: oldState, into: newState)
        }
    }

    static
    func automatically(
        scope: String = #file,
        context: String = #function,
        same: SameStateStrategy,
        body: ((@escaping SubmitAction) throws -> Void)? = nil
        ) -> Action
    {
        return automatically(scope: scope, context: context, same: same)
        {
            _, _, _, submit in

            //---

            try body?(submit)
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
        same: SameStateStrategy,
        body: @escaping (GlobalModel, SomeState, Become<S>, @escaping SubmitAction) throws -> Void
        ) -> Action
    {
        return Action(scope, context, self)
        {
            globalModel, submit in

            //---
            
            let oldState =
                
            try Require("\(F.name) is presented").isNotNil(
                
                globalModel >> F.self
            )

            //---

            try Require("Reset strategy satisfied").isFalse(

                (same == .no) && (oldState is S)
            )

            //---
            
            var newState: S!
            
            //---
            
            try body(globalModel, oldState, { newState = $0 }, submit)
            
            //---
            
            try Require("New state for \(F.name) is set").isNotNil(
                
                newState
            )
            
            //---
            
            return Transition(from: oldState, into: newState)
        }
    }

    static
    func via(
        scope: String = #file,
        context: String = #function,
        same: SameStateStrategy,
        body: @escaping (Become<S>, @escaping SubmitAction) throws -> Void
        ) -> Action
    {
        return via(scope: scope, context: context, same: same)
        {
            _, _, become, submit in

            //---

            try body(become, submit)
        }
    }
}
