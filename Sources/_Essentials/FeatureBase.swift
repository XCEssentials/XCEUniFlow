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

import Combine

//---

open
class FeatureBase
{
    private(set)
    var _dispatcher: StorageDispatcher!
    {
        didSet
        {
            activateSubscriptionsIfNeeded()
        }
    }
    
    private
    var subscriptions: [AnyCancellable] = []
    
    public
    init(
        with storageDispatcher: StorageDispatcher? = nil
    ) {
        self._dispatcher = storageDispatcher
        
        //---
        
        activateSubscriptionsIfNeeded()
    }
    
    public
    func configure(
        with storageDispatcher: StorageDispatcher
    ) {
        self._dispatcher = storageDispatcher
    }
    
    private
    func activateSubscriptionsIfNeeded()
    {
        if
            let observer = self as? SomeViewModel,
            let dispatcher = self._dispatcher
        {
            self.subscriptions = observer.observe(dispatcher)
        }
        else
        {
            self.subscriptions = []
        }
    }
    
    public
    func removeAllSubscriptions()
    {
        subscriptions = []
    }
    
    /// Group several read/write operations in one access report.
    public
    func access(
        scope: String = #file,
        context: String = #function,
        location: Int = #line,
        _ handler: () throws -> Void
    ) throws {
        
        // in uni-directionl data flow context we do not want to return anything directly
        // but we want to propagate thrown errors
        _ = try _dispatcher.access(
            scope: scope,
            context: context,
            location: location,
            { _ in try handler() }
        )
    }
    
    /// Wrap throwing piece of code and crash with `fatalError` if an error is thrown.
    ///
    /// We call "must" and "must not" words of obligation. "Must" is the only word that imposes
    /// a legal obligation on your readers to tell them something is mandatory.
    public
    func must(
        scope: String = #file,
        context: String = #function,
        location: Int = #line,
        _ handler: () throws -> Void
    ) {
        do
        {
            try _dispatcher.access(
                scope: scope,
                context: context,
                location: location,
                { _ in try handler() }
            )
        }
        catch
        {
            fatalError(error.localizedDescription)
        }
    }
    
    /// Wrap throwing piece of code and crash in DEBUG ONLY (via assertation) if an error is thrown.
    ///
    /// 'Shall' is used to express ideas and laws.
    public
    func shall(
        scope: String = #file,
        context: String = #function,
        location: Int = #line,
        _ handler: () throws -> Void
    ) {
        do
        {
            try _dispatcher.access(
                scope: scope,
                context: context,
                location: location,
                { _ in try handler() }
            )
        }
        catch
        {
            assertionFailure(error.localizedDescription)
        }
    }
    
    /// Wrap throwing piece of code and fail softly by ignoring thrown error.
    ///
    /// 'Should' is used to express personal opinions and desires, and primarily to give advice.
    @discardableResult
    public
    func should(
        scope: String = #file,
        context: String = #function,
        location: Int = #line,
        _ handler: () throws -> Void
    ) -> Bool {
        
        do
        {
            try _dispatcher.access(
                scope: scope,
                context: context,
                location: location,
                { _ in try handler() }
            )
            
            //---
            
            return true
        }
        catch
        {
            return false
        }
    }
}
