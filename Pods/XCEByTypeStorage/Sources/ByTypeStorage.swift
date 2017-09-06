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
final
class ByTypeStorage
{
    public
    init() {}
    
    //===
    
    typealias Key = String
    
    var data = [Key: Storable]()
    
    /**
     Id helps to avoid dublicates. Only one subscription is allowed per observer.
     */
    var subscriptions: [Subscription.Identifier: Subscription] = [:]
}

// MARK: - Key generation

extension ByTypeStorage.Key
{
    static
    func keyType<T>(for _: T.Type) -> Any.Type
    {
        if
            let StorableT = T.self as? Storable.Type
        {
            return StorableT.key
        }
        else
        {
            return T.self
        }
    }
    
    static
    func derived<T>(from _: T.Type) -> ByTypeStorage.Key
    {
        return ByTypeStorage.Key(reflecting: keyType(for: T.self))
    }
}
