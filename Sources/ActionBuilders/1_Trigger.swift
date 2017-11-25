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
extension Feature
{
    static
    var trigger: Trigger<Self>.Type
    {
        return Trigger<Self>.self
    }
}

//===

public
enum Trigger<F: Feature>
{
    public
    enum NoState: ActionKind { }
    
    public
    typealias Uninitialized = NoState
    
    public
    enum AnyState: ActionKind { }
    
    public
    typealias Initialized = AnyState
    
    public
    enum In<S: State>: ActionKind where S.Parent == F { }
    // swiftlint:disable:previous type_name
}

// MARK: - Action builders

public
extension Trigger.NoState
{
    static
    func via(
        scope: String = #file,
        context: String = #function,
        body: @escaping (GlobalModel, @escaping SubmitAction) throws -> Void
        ) -> Action
    {
        return Action(scope, context, self) { model, submit in
            
            try Require("\(F.name) is NOT presented yet").isNil(
                
                model >> F.self
            )
            
            //---
            
            try body(model, submit)
            
            //---
            
            return nil
        }
    }
}

//===

public
extension Trigger.AnyState
{
    static
    func via(
        scope: String = #file,
        context: String = #function,
        body: @escaping (GlobalModel, @escaping SubmitAction) throws -> Void
        ) -> Action
    {
        return Action(scope, context, self) { model, submit in
            
            try Require("\(F.name) is presented").isNotNil(
                
                model >> F.self
            )
            
            //---
            
            try body(model, submit)
            
            //---
            
            return nil
        }
    }
}

//===

public
extension Trigger.In
{
    static
    func via(
        scope: String = #file,
        context: String = #function,
        body: @escaping (S, @escaping SubmitAction) throws -> Void
        ) -> Action
    {
        return Action(scope, context, self) { model, submit in
            
            let currentState =
                
            try Require("\(F.name) is in \(S.self) state").isNotNil(
                
                model >> S.self
            )
            
            //---
            
            try body(currentState, submit)
            
            //---
            
            return nil
        }
    }
}
