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
extension StorageDispatcher
{
    func fetch<V: SomeState>(
        scope: String = #file,
        context: String = #function,
        location: Int = #line,
        valueOfType _: V.Type = V.self
    ) throws -> V {
        
        var result: V!
        
        //---
        
        try access(scope: scope, context: context, location: location) {
            
            result = try $0.fetch(valueOfType: V.self)
        }
        
        //---
        
        return result
    }
    
    //---
    
    func hasValue<V: SomeState>(
        scope: String = #file,
        context: String = #function,
        location: Int = #line,
        ofType _: V.Type
    ) -> Bool {
        
        do
        {
            _ = try fetch(
                scope: scope,
                context: context,
                location: location,
                valueOfType: V.self
            )
            
            return true
        }
        catch
        {
            return false
        }
    }
}

//---

public
extension SomeState
{
    static
    func fetch(
        scope: String = #file,
        context: String = #function,
        location: Int = #line,
        from storage: StorageDispatcher
    ) throws -> Self {
        
        try storage.fetch(
            scope: scope,
            context: context,
            location: location,
            valueOfType: self
        )
    }
    
    //---
    
    static
    func isPresent(
        scope: String = #file,
        context: String = #function,
        location: Int = #line,
        in storage: StorageDispatcher
    ) -> Bool {
        
        storage.hasValue(
            scope: scope,
            context: context,
            location: location,
            ofType: self
        )
    }
}
