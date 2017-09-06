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
protocol ActionContext { }

//===

public
extension ActionContext
{
    
//    // This kind of general action is NOT allowed, because it does not guarantee
//    // that requested mutations are eligible on the global model. It's required that user
//    // uses one of provided convenient mutation helpers - they do necessary chacks
//    // before proceed to user provided custom code and isolate user from
//    // accessing global model directly.
//    
//    static
//    func action(
//        scope: String = #file,
//        context: String = #function,
//        body: @escaping (GlobalModel, SubmitMutations, @escaping SubmitAction) throws -> Void
//        ) -> Action
//    {
//        return Action(scope, context, self) { model, submit in
//
//            var mutations: [GlobalMutation] = []
//
//            //---
//
//            try body(model, { mutations.append(contentsOf: $0) }, submit)
//
//            //---
//
//            return mutations.isEmpty ? nil : mutations
//        }
//    }
    
    //===
    
    static
    func trigger(
        scope: String = #file,
        context: String = #function,
        body: @escaping (GlobalModel, @escaping SubmitAction) throws -> Void
        ) -> Action
    {
        return Action(scope, context, self) { model, submit in
            
            try body(model, submit)
            
            //---
            
            return nil
        }
    }
}
