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

import XCEPipeline

//---

public
extension Transition
{
    struct From<S: State>: ActionKind where S.Parent == F
    {
        public
        let oldState: S
        
        //---
        
        init(_ oldState: S)
        {
            self.oldState = oldState
        }
        
        //---
        
        /**
         Usage:
         
         ```swift
         let appRunning = TransitionFrom<M.App.Running>(diff)?.oldState
         ```
         */
        public
        init?(_ mutation: GlobalMutation?)
        {
            guard
                let mutation = mutation as? Transition<S.Parent>,
                let oldState = mutation.oldState as? S
            else
            {
                return nil
            }
            
            //---
            
            self = TransitionFrom(oldState)
        }
    }
}

//---

public
typealias TransitionFrom<S: State> = Transition<S.Parent>.From<S>

// MARK: - Action builders

public
extension Transition.From
{
    static
    func into<Into: State>(
        scope: String = #file,
        context: String = #function,
        _ newState: Into,
        body: ((GlobalModel, S, @escaping SubmitAction) throws -> Void)? = nil
        ) -> Action
        where Into.Parent == F
    {
        return Action(scope, context, self)
        {
            globalModel, submit in

            //---

            let oldState = try globalModel
                >> S.self
                ./ {
                    try $0 ?! UniFlowError.featureIsNotInState(
                        F.self,
                        expected: S.self,
                        actual: try? globalModel.state(for: F.self)
                    )
                }
               
            //---

            try body?(globalModel, oldState, submit)

            //---
            
            return Transition(from: oldState, into: newState)
        }
    }
}
