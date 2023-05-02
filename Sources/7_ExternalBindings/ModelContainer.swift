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

/// Basic model wrapper type implementation to use as super class for
/// view models (e.g. in `SwiftUI`) with built-in storage for feature instance,
/// which is considered to be Model layer (according to MVVM pattern).
///
/// In case `M` is a `FeatureBase` subclass - it provides default
/// initialization and configuration functions that pass through
/// `dispatcher` straight into the `model` and also activate bindings
/// in case `Self` is also an external observer (a.k.a. `SomeExternalObserver`).
open
class ModelContainer<T: SomeFeature>
{
    public
    typealias M = T
    
    /// Corresponding model instance, which is supposed to be used
    /// to pass input from View to Model layer.
    public
    let model = M()
    
    public
    var isReady: Bool
    {
        model.isReady
    }
    
    public
    required
    init() {}
    
    deinit
    {
        (model as? WithCleanupAction)?.cleanup()
    }

    /// Configure `model` to use given `dispatcher`,
    /// if it has not been configured yet,  and
    /// activate subscriptions, if possible.
    ///
    /// This is designated point of initilization,
    /// override and extend this function to access
    /// corresponding dispatcher via `model`, configure
    /// instance of custom subclass and throw any
    /// access errors to the upper layer.
    ///
    /// - Throws: if it has been already configured earlier.
    open
    func makeReady(
        with dispatcher: Dispatcher
    ) throws {
        
        try model.makeReady(with: dispatcher)
        
        //---
        
        (self as? SomeExternalObserver)
            .map { $0.activateSubscriptions(with: dispatcher) }
    }
}
