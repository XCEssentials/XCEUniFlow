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

/**
 Conformance to this protocol allows an instance of 'Self' type to be stored in any 'ByTypeStorage' instance.
 */
public
protocol Storable
{
    /**
     The type that should be used as a key inside 'ByTypeStorage' instance. By default, 'ByTypeStorage' uses this type itself as a key for storing an instance of this type. Custom implementation of this property allows to override default behaviour of 'ByTypeStorage' instance when dealing with these types. It enables interesting technique, when several different types can declare same type as their key type, making instances of these types to be "mutually exclusive" within the same given storage, so they will override each other.
     */
    static
    var key: Any.Type { get }
}

public
extension Storable
{
    /**
     By default, 'ByTypeStorage' uses this type itself as a key for storing an instance of this type.
     */
    static
    var key: Any.Type
    {
        return self
    }
}

//===

public
protocol StorageObserver: class
{
    func update(with change: ByTypeStorage.Change, in storage: ByTypeStorage)
}

//===

public
protocol StorageInitializable
{
    init(with storage: ByTypeStorage)
}

//===

public
protocol StorageBindable
{
    func bind(with storage: ByTypeStorage) -> Self
}
