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
extension BDD.GivenOrThenContext where S: SomeWorkflow
{
    func then(
        scope: String = #file,
        location: Int = #line,
        _ then: @escaping (StorageDispatcher, W.Output) -> Void
    ) -> MutationBinding {
        
        .init(
            source: S.self,
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
        _ dispatcherOnlyHandler: @escaping (StorageDispatcher) -> Void
    ) -> MutationBinding {
        
        then(scope: scope, location: location) { dispatcher, _ in
            
            dispatcherOnlyHandler(dispatcher)
        }
    }
}

//---

public
extension BDD.ThenContext where S: SomeWorkflow
{
    func then(
        scope: String = #file,
        location: Int = #line,
        _ then: @escaping (StorageDispatcher, G) -> Void
    ) -> MutationBinding {
        
        .init(
            source: S.self,
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
        _ dispatcherOnlyHandler: @escaping (StorageDispatcher) -> Void
    ) -> MutationBinding {
        
        then(scope: scope, location: location) { dispatcher, _ in
            
            dispatcherOnlyHandler(dispatcher)
        }
    }
}
