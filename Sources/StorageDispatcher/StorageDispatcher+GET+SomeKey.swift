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
    func fetch(
        scope: String = #file,
        context: String = #function,
        location: Int = #line,
        valueForKey keyType: SomeKey.Type
    ) throws -> SomeStorableBase {
        
        var result: SomeStorableBase!
        
        //---
        
        try access(scope: scope, context: context, location: location) {
            
            result = try $0.fetch(valueForKey: keyType)
        }
        
        //---
        
        return result
    }
    
    func hasValue(
        scope: String = #file,
        context: String = #function,
        location: Int = #line,
        withKey keyType: SomeKey.Type
    ) -> Bool {
        
        do
        {
            _ = try fetch(
                scope: scope,
                context: context,
                location: location,
                valueForKey: keyType
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
extension SomeKey
{
    static
    func fetch(
        scope: String = #file,
        context: String = #function,
        location: Int = #line,
        from storage: StorageDispatcher
    ) throws -> SomeStorableBase {
        
        try storage.fetch(
            scope: scope,
            context: context,
            location: location,
            valueForKey: self
        )
    }
    
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
            withKey: self
        )
    }
}
