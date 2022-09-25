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

import XCEPipeline

//---

// MARK: - Semantic transaction helpers

public
extension SomeFeature
{
    @discardableResult
    func execute<T>(
        scope: String = #file,
        context: String = #function,
        location: Int = #line,
        _ handler: () throws -> T
    ) throws -> T {
        
        try dispatcher
            .transact(
                scope: scope,
                context: context,
                location: location,
                handler
            )
            .get()
    }
    
    /// Transaction within `handler` must be successful,
    /// or a critical error will be thrown (in `DEBUG` mode only).
    @discardableResult
    func must<T>(
        scope: String = #file,
        context: String = #function,
        location: Int = #line,
        _ handler: () throws -> T
    ) -> Result<T, Error> {
        
        let result = dispatcher
            .transact(
                scope: scope,
                context: context,
                location: location,
                handler
            )
        
        //---
        
        #if DEBUG
        
        if
            case .failure(let report) = result
        {
            assertionFailure("❌ [UniFlow] Transaction failed: \(report)")
        }
        
        #endif
        
        //---
        
        return result
    }
    
    /// Transaction within `handler` may fail,
    /// but failure is an acceptable outcome,
    /// so no errors will be reported.
    @discardableResult
    func should<T>(
        scope: String = #file,
        context: String = #function,
        location: Int = #line,
        _ handler: () throws -> T
    ) -> Result<T, Error> {
        
        dispatcher
            .transact(
                scope: scope,
                context: context,
                location: location,
                handler
            )
    }
}
