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
typealias ModelBinding =
    (GlobalModel, GlobalMutation, @escaping SubmitAction) throws -> Void

// MARK: - Register global model bindings

public
extension Dispatcher
{
    private
    enum GlobalModelBinding
    {
        static
        var groupId: ModelBindingGroupId
        {
            return ModelBindingGroupId(reflecting: self)
        }
    }
    
    //===
    
    func registerGlobalBinding(_ handler: @escaping ModelBinding)
    {
        var globals = bindings[GlobalModelBinding.groupId] ?? []
        globals.append(handler)
        bindings[GlobalModelBinding.groupId] = globals
    }
    
    //===
    
    func registerGlobalBindings(_ handlers: [ModelBinding])
    {
        var globals = bindings[GlobalModelBinding.groupId] ?? []
        globals.append(contentsOf: handlers)
        bindings[GlobalModelBinding.groupId] = globals
    }
}

// MARK: - Helper ModelBinding builder

public
extension MutationConvertible
{
    static
    func bind(
        _ handler: @escaping (GlobalModel, Self, @escaping SubmitAction) -> Void
        ) -> ModelBinding
    {
        return { globalModel, mutation, submit in

            self.init(mutation).map { handler(globalModel, $0, submit) }
        }
    }
}
