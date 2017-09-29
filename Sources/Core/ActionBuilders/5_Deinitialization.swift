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
    var deinitialize: Deinitialization<Self>.Type
    {
        return Deinitialization<Self>.self
    }
}

//===

public
struct Deinitialization<F: Feature>: ActionKind, FeatureRemoval
{
    var relatedToFeature: Feature.Type
    {
        return F.self
    }
    
    public
    let oldState: SomeState
    
    //===
    
    init(from oldState: SomeState)
    {
        self.oldState = oldState
    }
    
    //===
    
    /**
     Usage:
     
     ```swift
     let someAppState = Deinitialization<M.App>(diff)?.oldState
     ```
     */
    public
    init?(_ mutation: GlobalMutation?)
    {
        guard
            let mutation = mutation as? Deinitialization<F>
        else
        {
            return nil
        }
        
        //---
        
        self = mutation
    }
}

// MARK: - Action builders

public
extension Deinitialization
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
            
            completion?(submit)
            
            //---
            
            return self.init(from: oldState)
        }
    }
    
    //===
    
    static
    func prepare(
        scope: String = #file,
        context: String = #function,
        body: @escaping (GlobalModel, @escaping SubmitAction) throws -> Void
        ) -> Action
    {
        return Action(scope, context, self) { model, submit in
            
            let oldState =
                
            try Require("\(F.name) is presented").isNotNil(
                
                model >> F.self
            )
            
            //---
            
            try body(model, submit)
            
            //---
            
            return self.init(from: oldState)
        }
    }
}
