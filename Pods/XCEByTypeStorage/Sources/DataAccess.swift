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

// MARK: - GET data

public
extension ByTypeStorage
{
    func value<T: Storable>(of _: T.Type) -> T?
    {
        return data[Key.derived(from: T.self)] as? T
    }
    
    func value<T>(forKey _: T.Type) -> Storable?
    {
        return data[Key.derived(from: T.self)]
    }
    
    //===
    
    func hasValue<T: Storable>(of _: T.Type) -> Bool
    {
        return value(of: T.self) != nil
    }
    
    func hasValue<T>(forKey _: T.Type) -> Bool
    {
        return value(forKey: T.self) != nil
    }
}

//===

public
extension Storable
{
    static
    func from(_ storage: ByTypeStorage) -> Self?
    {
        return storage.value(of: self)
    }
    
    //===
    
    static
    func presented(in storage: ByTypeStorage) -> Bool
    {
        return storage.hasValue(of: self)
    }
}

// MARK: - SET data

public
extension ByTypeStorage
{
    func storeValue<T: Storable>(_ value: T?)
    {
        let change: Change
            
        if
            hasValue(of: T.self)
        {
            change = .update(forKey: Key.keyType(for: T.self))
        }
        else
        {
            change = .addition(forKey: Key.keyType(for: T.self))
        }
        
        //---
        
        data[Key.derived(from: T.self)] = value
        
        //---
        
        notifyObservers(with: change)
    }
}

//===

public
extension Storable
{
    @discardableResult
    func store(in storage: ByTypeStorage) -> Self
    {
        storage.storeValue(self)
        
        //---
        
        return self
    }
}

// MARK: - REMOVE data

public
extension ByTypeStorage
{
    func removeValue<T: Storable>(of _: T.Type)
    {
        guard
            hasValue(of: T.self)
        else
        {
            return
        }
        
        //---
        
        data[Key.derived(from: T.self)] = nil
        
        //---
        
        notifyObservers(with: Change.removal(forKey: Key.keyType(for: T.self)))
    }
    
    func removeValue<T>(forKey _: T.Type)
    {
        guard
            hasValue(forKey: T.self)
        else
        {
            return
        }
        
        //---
        
        data[Key.derived(from: T.self)] = nil
        
        //---
        
        notifyObservers(with: Change.removal(forKey: Key.keyType(for: T.self)))
    }
}

//===

public
extension Storable
{
    static
    func remove(from storage: ByTypeStorage)
    {
        return storage.removeValue(of: self)
    }
}
