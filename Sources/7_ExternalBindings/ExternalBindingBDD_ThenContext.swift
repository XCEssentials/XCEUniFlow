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
extension ExternalBindingBDD
{
    struct ThenContext<W: SomeMutationDecriptor, G> // W - When, G - Given
    {
        public
        let description: String
        
        //internal
        let given: (Dispatcher, W) throws -> G?
        
        public
        func then(
            scope: String = #file,
            location: Int = #line,
            _ then: @escaping (Dispatcher, G) -> Void
        ) -> ExternalBinding {
            
            .init(
                description: description,
                scope: scope,
                context: S.self,
                location: location,
                given: given,
                then: then
            )
        }
        
        public
        func then(
            scope: String = #file,
            location: Int = #line,
            _ noDispatcherHandler: @escaping (G) -> Void
        ) -> ExternalBinding {
            
            then(scope: scope, location: location) { _, input in
                
                noDispatcherHandler(input)
            }
        }
        
        public
        func then(
            scope: String = #file,
            location: Int = #line,
            _ sourceOnlyHandler: @escaping () -> Void
        ) -> ExternalBinding where G == Void {
            
            then(scope: scope, location: location) { _, _ in
                
                sourceOnlyHandler()
            }
        }
    }
}
