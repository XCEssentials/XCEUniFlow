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
extension Initialization
{
    struct Into<S: State>: ActionKind where S.Parent == F
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
         let appRunning = InitializationInto<M.App.Running>(diff)?.newState
         ```
         */
        public
        init?(_ mutation: GlobalMutation?)
        {
            guard
                let mutation = mutation as? Initialization<F>,
                let newState = mutation.newState as? S
            else
            {
                return nil
            }
            
            //---
            
            self = InitializationInto(newState)
        }
    }
}

//===

public
typealias InitializationInto<S: State> = Initialization<S.Parent>.Into<S>

// MARK: - Action builders

public
extension Initialization.Into where S: AutoInitializable
{
    static
    func automatically(
        scope: String = #file,
        context: String = #function,
        completion: ((@escaping SubmitAction) -> Void)? = nil
        ) -> Action
    {
        return Action(scope, context, self) { model, submit in
            
            try Require("\(F.name) is NOT initialized yet").isNil(
                
                model >> F.self
            )
            
            //---
            
            let newState = S.init()
            
            //---
            
            completion?(submit)
            
            //---
            
            return Initialization(into: newState)
        }
    }
}

//===

public
extension Initialization.Into
{
    static
    func via(
        scope: String = #file,
        context: String = #function,
        body: @escaping (Become<S>, @escaping SubmitAction) throws -> Void
        ) -> Action
    {
        return Action(scope, context, self) { model, submit in
            
            try Require("\(F.name) is NOT initialized yet").isNil(
                
                model >> F.self
            )
            
            //---
            
            var newState: S!
            
            //---
            
            try body({ newState = $0 }, submit)
            
            //---
            
            try Require("New state for \(F.name) is set").isNotNil(
                
                newState
            )
            
            //---
            
            return Initialization(into: newState)
        }
    }
}
