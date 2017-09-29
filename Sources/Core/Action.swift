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

//===

public
typealias SubmitAction = (Action) -> Void

//===

public
typealias Become<S: State> = (S) -> Void

//===

typealias ActionBody =
    (GlobalModel, @escaping SubmitAction) throws -> GlobalMutationExt?

//===

/**
 A type that conforms to this protocol has a semantic value and represents a distinctive set of actions.
 */
public
protocol ActionKind: MutationConvertible { }

//===

public
struct Action
{
    public
    let scope: String
    
    public
    let context: String
    
    public
    let kind: ActionKind.Type
    
    //===
    
    let body: ActionBody
    
    //===
    
    /**
     NOTE: constructor is unavailable directly from outside of the module!
     */
    init(
        _ scope: String,
        _ context: String,
        _ kind: ActionKind.Type,
        _ body: @escaping ActionBody
        )
    {
        self.scope = scope
        self.context = context
        self.kind = kind
        self.body = body
    }
}

// MARK: - Debug helpers

public
extension Action
{
    var name: String { return "\(context)@\(scope)" }
    var kindDescription: String { return String(reflecting: kind) }
    var description: String { return "\(kindDescription) // \(name)" }
}

// MARK: - Direct execution helper (mostly unit tests helper)

extension Action
{
    func perform(
        with currentState: GlobalModel,
        submitHandler: SubmitAction? = nil
        ) throws -> GlobalMutation?
    {
        return try body(currentState, submitHandler ?? { _ in })
    }
}
