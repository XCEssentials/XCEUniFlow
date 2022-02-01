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
protocol SomeFeature: SomeStateful {}

//---

public
extension SomeFeature
{
    typealias Itself = Self
}

//---

public
extension SomeFeature where Self: FeatureBase
{
    @discardableResult
    func fetch<V: SomeState>(
        scope: String = #file,
        context: String = #function,
        location: Int = #line,
        _ valueOfType: V.Type = V.self
    ) throws -> V {
        
        try _dispatcher.fetch(
            scope: scope,
            context: context,
            location: location,
            valueOfType: V.self
        )
    }
    
    @discardableResult
    func store<V: SomeState>(
        scope: String = #file,
        context: String = #function,
        location: Int = #line,
        _ value: V
    ) throws -> ByTypeStorage.History where V.Feature == Self {
        
        try _dispatcher.access(scope: scope, context: context, location: location) {
            
            try $0.store(value)
        }
    }
    
    @discardableResult
    func initialize<V: SomeState>(
        scope: String = #file,
        context: String = #function,
        location: Int = #line,
        with newValue: V
    ) throws -> ByTypeStorage.History where V.Feature == Self {
        
        try _dispatcher.access(scope: scope, context: context, location: location) {
            
            try $0.initialize(with: newValue)
        }
    }
    
    @discardableResult
    func actualize<V: SomeState>(
        scope: String = #file,
        context: String = #function,
        location: Int = #line,
        _ valueOfType: V.Type = V.self,
        via mutationHandler: (inout V) throws -> Void
    ) throws -> ByTypeStorage.History where V.Feature == Self {
        
        try _dispatcher.access(scope: scope, context: context, location: location) {
           
            try $0.actualize(V.self, via: mutationHandler)
        }
    }
    
    @discardableResult
    func actualize<V: SomeState>(
        scope: String = #file,
        context: String = #function,
        location: Int = #line,
        with newValue: V
    ) throws -> ByTypeStorage.History where V.Feature == Self {
        
        try _dispatcher.access(scope: scope, context: context, location: location) {
           
            try $0.actualize(with: newValue)
        }
    }
    
    @discardableResult
    func transition<O: SomeState, N: SomeState>(
        scope: String = #file,
        context: String = #function,
        location: Int = #line,
        from oldValueInstance: O,
        into newValue: N
    ) throws -> ByTypeStorage.History where O.Feature == Self, N.Feature == Self {
        
        try _dispatcher.access(scope: scope, context: context, location: location) {
           
            try $0.transition(from: oldValueInstance, into: newValue)
        }
    }
    
    @discardableResult
    func transition<O: SomeState, N: SomeState>(
        scope: String = #file,
        context: String = #function,
        location: Int = #line,
        from oldValueType: O.Type,
        into newValue: N
    ) throws -> ByTypeStorage.History where O.Feature == Self, N.Feature == Self {
        
        try _dispatcher.access(scope: scope, context: context, location: location) {
           
            try $0.transition(from: O.self, into: newValue)
        }
    }
    
    @discardableResult
    func transition<V: SomeState>(
        scope: String = #file,
        context: String = #function,
        location: Int = #line,
        into newValue: V
    ) throws -> ByTypeStorage.History where V.Feature == Self {
        
        try _dispatcher.access(scope: scope, context: context, location: location) {
           
            try $0.transition(into: newValue)
        }
    }
    
    @discardableResult
    func deinitialize(
        scope: String = #file,
        context: String = #function,
        location: Int = #line,
        strict: Bool = true
    ) throws -> ByTypeStorage.History {
        
        try _dispatcher.access(scope: scope, context: context, location: location) {
           
            try $0.deinitialize(Self.self, fromValueType: nil, strict: strict)
        }
    }
    
    @discardableResult
    func deinitialize<V: SomeState>(
        scope: String = #file,
        context: String = #function,
        location: Int = #line,
        from fromValueType: V.Type
    ) throws -> ByTypeStorage.History where V.Feature == Self {
        
        try _dispatcher.access(scope: scope, context: context, location: location) {
           
            try $0.deinitialize(Self.self, fromValueType: fromValueType, strict: true)
        }
    }
}
