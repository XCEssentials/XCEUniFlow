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
protocol Feature {}

public
extension Feature
{
    /// `Storage` will use this as actual key.
    static
    var name: String
    {
        // full type name, including enclosing types for nested declarations:
        return .init(reflecting: Self.self)
    }
    
    /// Convenience helper that determines user-friendly feature name.
    static
    var displayName: String
    {
        if
            let customizedSelf = Self.self as? any WithCustomDisplayName.Type
        {
            return customizedSelf.customDisplayName
        }
        else
        {
            return Self
                .name
                .split(separator: ".")
                .dropFirst() // drop app/module name
                .joined(separator: ".")
                .split(separator: ":")
                .last
                .map(String.init) ?? ""
        }
    }
    
    @MainActor
    static
    func at(_ dispatcher: Dispatcher) -> ActionContext<Self>
    {
        .init(with: dispatcher)
    }
}
