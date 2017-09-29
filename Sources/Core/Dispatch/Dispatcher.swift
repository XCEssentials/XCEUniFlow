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
final
class Dispatcher
{
    // MARK: - Private members
    
    var state = GlobalModel()

    var bindings: [ModelBinding.GroupId: [ModelBinding]] = [:]
    
    var subscriptions: [Subscription.Identifier: Subscription] = [:]
    
    // MARK: - Public members
    
    public
    lazy
    var proxy: Proxy = Proxy(for: self)
    
    public
    var onDidProcessAction: ((_ action: Action) -> Void)?
    
    public
    var onDidRejectAction: ((_ action: Action, _: Error) -> Void)?

    public
    var onDidProcessBinding: ((_ binding: String) -> Void)?

    public
    var onDidRejectBinding: ((_ binding: String, _: Error) -> Void)?

    // MARK: - Public initializers
    
    public
    init(defaultReporting: DefaultReporting = .none)
    {
        switch defaultReporting
        {
            case .short:
                enableShortDefaultReporting()
            
            case .verbose:
                enableVerboseDefaultReporting()
            
            default:
                break
        }
    }
    
    // MARK: - Public nested types
    
    public
    final
    class Proxy
    {
        //  https://en.wikipedia.org/wiki/Proxy_pattern
        
        let dispatcher: Dispatcher
        
        init(for dispatcher: Dispatcher)
        {
            self.dispatcher = dispatcher
        }
    }
}
