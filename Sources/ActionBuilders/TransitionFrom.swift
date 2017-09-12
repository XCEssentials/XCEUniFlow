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
    struct From<S: FeatureState>: ActionKind where S.ParentFeature == F
    {
        public
        let oldState: S
        
        //===
        
        init(_ oldState: S)
        {
            self.oldState = oldState
        }
        
        //===
        
        /**
         Usage:
         
         ```swift
         let appRunning = TransitionFrom<M.App.Running>(diff)?.oldState
         ```
         */
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
            
            self = TransitionFrom(oldState)
        }
    }
}

//===

public
typealias TransitionFrom<S: FeatureState> = Transition<S.ParentFeature>.From<S>

// MARK: - Action builders

public
extension Transition.From
{
    static
    func into<Into: FeatureState>(
        scope: String = #file,
        context: String = #function,
        _ newState: Into
        ) -> Action
        where Into.ParentFeature == F
    {
        return Action(scope, context, self) { model, _ in
            
            let oldState =
                
            try Require("\(F.name) is in \(S.self) state").isNotNil(
                
                model >> S.self
            )
            
            //---
            
            return Transition(from: oldState, into: newState)
        }
    }
}