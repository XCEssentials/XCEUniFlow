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

public
extension BDDViewModel
{
    struct GivenOrThenContext<W: Publisher> // W - When
    {
        public
        let description: String
        
        weak
        var source: S!
        
        //internal
        let when: (AnyPublisher<StorageDispatcher.AccessReport, Never>) -> W
        
        public
        func given<G>(
            _ given: @escaping (StorageDispatcher, W.Output) throws -> G?
        ) -> ThenContext<W, G> {
            
            .init(
                description: description,
                when: when,
                given: given
            )
        }
        
        public
        func given<G>(
            _ outputOnlyHandler: @escaping (W.Output) throws -> G?
        ) -> ThenContext<W, G> {
            
            given { _, output in
                
                try outputOnlyHandler(output)
            }
        }
        
        public
        func then(
            scope: String = #file,
            location: Int = #line,
            _ then: @escaping (S, W.Output, StorageDispatcher.StatusProxy) -> Void
        ) -> BindingViewModel {
            
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
        
        public
        func then(
            scope: String = #file,
            location: Int = #line,
            _ noInputHandler: @escaping (S, StorageDispatcher.StatusProxy) -> Void
        ) -> BindingViewModel {
            
            then(scope: scope, location: location) { src, _, proxy in
                
                noInputHandler(src, proxy)
            }
        }
        
        public
        func then(
            scope: String = #file,
            location: Int = #line,
            _ sourceOnlyHandler: @escaping (S) -> Void
        ) -> BindingViewModel {
            
            then(scope: scope, location: location) { src, _ in
                
                sourceOnlyHandler(src)
            }
        }
    }
}
