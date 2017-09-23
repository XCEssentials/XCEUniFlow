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

import Foundation

//===

public
extension Dispatcher
{
    final
    class Subscription
    {
        fileprivate(set)
        weak
        var observer: StateObserver?
        
        init(with observer: StateObserver)
        {
            self.observer = observer
        }
        
        typealias Identifier = ObjectIdentifier
        
        lazy
        var identifier: Identifier = Identifier(self)
    }
}

// MARK: - Subscription - internal methods

extension Dispatcher.Subscription
{
    @discardableResult
    func notifyAndKeep(with state: GlobalModel, mutation: GlobalMutation) -> Bool
    {
        guard
            let observer = observer
        else
        {
            return false
        }
        
        //---
        
        type(of: observer).bindings.forEach {

            try? $0.execute(with: state,
                            mutation: mutation,
                            observer: observer)
        }

        //---
        
        return true
    }
}

// MARK: - Subscription - public methods

public
extension Dispatcher.Subscription
{
    func cancel()
    {
        observer = nil
    }
}

// MARK: Proxy extensions for subscriptions

public
extension Dispatcher.Proxy
{
    @discardableResult
    public
    func subscribe(
        _ observer: StateObserver,
        forceUpdateNow: Bool = false
        ) -> Dispatcher.Subscription
    {
        let result = Dispatcher.Subscription(with: observer)
        dispatcher.subscriptions[result.identifier] = result
        
        //---
        
        if
            forceUpdateNow
        {
            updateNow(observer)
        }
        
        //---
        
        return result
    }
    
    //===

    public
    func updateNow(_ observer: StateObserver)
    {
        type(of: observer).bindings.forEach {

            try? $0.execute(with: self.dispatcher.state,
                            mutation: nil,
                            observer: observer)
        }
    }
}
