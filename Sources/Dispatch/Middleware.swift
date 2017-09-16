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
extension Dispatcher
{
    typealias Middleware =
        (GlobalModel, GlobalMutation, @escaping SubmitAction)throws -> Void
}

// MARK: - Register global middleware

public
extension Dispatcher
{
    private
    enum GlobalMiddleware
    {
        static
        var key: GlobalModel.Key
        {
            return GlobalModel.Key(reflecting: self)
        }
    }
    
    //===
    
    func registerGlobalMiddleware(_ handler: @escaping Middleware)
    {
        var globals = middleware[GlobalMiddleware.key] ?? []
        globals.append(handler)
        middleware[GlobalMiddleware.key] = globals
    }
    
    //===
    
    func registerGlobalMiddleware(_ handlers: [Middleware])
    {
        var globals = middleware[GlobalMiddleware.key] ?? []
        globals.append(contentsOf: handlers)
        middleware[GlobalMiddleware.key] = globals
    }
}

// MARK: - Semantic middleware builders

public
typealias ActionKindBinding<AK: ActionKind> =
    (GlobalModel, AK, @escaping SubmitAction) -> Void

public
extension ActionKind
{
    static
    func bind(
        _ handler: @escaping ActionKindBinding<Self>
        ) -> Dispatcher.Middleware
    {
        return { globalModel, mutation, submit in

            self.init(mutation).map { handler(globalModel, $0, submit) }
        }
    }
    
//    static
//    var chain: Connector<Self>
//    {
//        return
//    }
    
//    static
//    func map(_ handler: @escaping ActionKindBinding<Self>) -> Connector
//    {
//        return Connector { globalModel, mutation, submit in
//
//            self.init(mutation).map { handler(globalModel, $0, submit) }
//        }
//    }
}

//===

public
struct Connector<T>
{
    let value: T
    let handler: Dispatcher.Middleware
}

public
extension Connector
{
//    func finally()
}

//===

//public
//struct ActionBindingConnector<AK: ActionKind>
//{
//    public
//    func submit(_ actions: [Action]) -> Dispatcher.Middleware
//    {
//        return { globalModel, mutation, submit in
//
//            AK.init(mutation).map {
//
//                submit << actions
//            }
//        }
//    }
//
//    public
//    func submit(_ action: Action) -> Dispatcher.Middleware
//    {
//        return submit([action])
//    }
//}

//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
