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
extension BDD.GivenOrThenContext where S: SomeDispatcherObserver
{
    func then(
        scope: String = #file,
        location: Int = #line,
        with source: S,
        _ then: @escaping (S, W.Output) -> Void
    ) -> Binding {
        
        .init(
            source: source,
            description: description,
            scope: scope,
            location: location,
            when: when,
            given: { $1 }, /// just pass `when` clause output straight through as is
            then: then
        )
    }
    
    func then(
        scope: String = #file,
        location: Int = #line,
        with source: S,
        _ sourceOnlyHandler: @escaping (S) -> Void
    ) -> Binding {
        
        then(scope: scope, location: location, with: source) { src, _ in
            
            sourceOnlyHandler(src)
        }
    }
    
    func then(
        scope: String = #file,
        location: Int = #line,
        with source: S,
        _ outputOnlyHandler: @escaping (W.Output) -> Void
    ) -> Binding {
        
        then(scope: scope, location: location, with: source) { _, output in
            
            outputOnlyHandler(output)
        }
    }
}

//---

public
extension BDD.ThenContext where S: SomeDispatcherObserver
{
    func then(
        scope: String = #file,
        location: Int = #line,
        with source: S,
        _ then: @escaping (S, G) -> Void
    ) -> Binding {
        
        .init(
            source: source,
            description: description,
            scope: scope,
            location: location,
            when: when,
            given: given,
            then: then
        )
    }
    
    func then(
        scope: String = #file,
        location: Int = #line,
        with source: S,
        _ sourceOnlyHandler: @escaping (S) -> Void
    ) -> Binding {
        
        then(scope: scope, location: location, with: source) { src, _ in
            
            sourceOnlyHandler(src)
        }
    }
    
    func then(
        scope: String = #file,
        location: Int = #line,
        with source: S,
        _ outputOnlyHandler: @escaping (G) -> Void
    ) -> Binding {
        
        then(scope: scope, location: location, with: source) { _, output in
            
            outputOnlyHandler(output)
        }
    }
}
