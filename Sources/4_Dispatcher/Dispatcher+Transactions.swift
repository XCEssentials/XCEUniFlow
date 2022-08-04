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
extension Dispatcher
{
    /// Indicates how an error should be reported
    enum CriticalErrorReportingMethod
    {
        /// Via `fatalError`
        case fatalError
        
        /// Via `assertionFailure`
        case assertation
    }
    
    /// Transaction within `handler` must be successful,
    /// or a critical error will be reported.
    @discardableResult
    func must(
        scope: String = #file,
        context: String = #function,
        location: Int = #line,
        reportVia reportingMethod: CriticalErrorReportingMethod = .assertation,
        _ handler: () throws -> Void
    ) -> Storage.History? {
        
        try? transact(
            scope: scope,
            context: context,
            location: location,
            extraFailureReporting: reportingMethod,
            handler
        )
    }
    
    /// Transaction within `handler` may fail,
    /// but failure is an acceptable outcome
    /// o no errors will be reported.
    @discardableResult
    func should(
        scope: String = #file,
        context: String = #function,
        location: Int = #line,
        _ handler: () throws -> Void
    ) -> Storage.History? {
        
        try? transact(
            scope: scope,
            context: context,
            location: location,
            extraFailureReporting: .none,
            handler
        )
    }
    
    @discardableResult
    func transact(
        scope: String = #file,
        context: String = #function,
        location: Int = #line,
        extraFailureReporting: CriticalErrorReportingMethod? = nil,
        _ handler: () throws -> Void
    ) rethrows -> Storage.History {

        try! startTransaction(
            scope: scope,
            context: context,
            location: location
        )

        //---

        do
        {
            try handler()
        }
        catch
        {
            try! rejectTransaction(
                scope: scope,
                context: context,
                location: location,
                reason: error
            )

            switch extraFailureReporting
            {
                case .fatalError:
                    fatalError("\(error)")
                    
                case .assertation:
                    assertionFailure("\(error)")
                    
                case .none:
                    break
            }
            
            throw error
        }

        //---

        return try! commitTransaction(
            scope: scope,
            context: context,
            location: location
        )
    }
}
