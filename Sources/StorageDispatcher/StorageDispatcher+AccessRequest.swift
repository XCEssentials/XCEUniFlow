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
extension StorageDispatcher
{
    struct AccessRequest
    {
        public
        typealias Body = StorageDispatcher.AccessHandler
        
        //---
        
        public
        let scope: String
        
        public
        let context: String
        
        public
        let location: Int
        
        public
        let body: Body
        
        //---
        
        public
        init(
            scope: String = #file,
            context: String = #function,
            location: Int = #line,
            handler: @escaping Body
        ) {

            self.scope = scope
            self.context = context
            self.location = location
            self.body = handler
        }
    }
}

// MARK: - SET data

public
extension StorageDispatcher
{
    @discardableResult
    func process(
        _ request: AccessRequest
    ) throws -> ByTypeStorage.History {

        try process([request])
    }
    
    @discardableResult
    func process(
        _ requests: [AccessRequest]
    ) throws -> ByTypeStorage.History {

        try requests
            .flatMap {
                
                try access(
                    scope: $0.scope,
                    context: $0.context,
                    location: $0.location,
                    $0.body
                )
            }
    }
}
