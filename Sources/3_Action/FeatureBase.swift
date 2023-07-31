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

/// Generic feature implementation.
@MainActor
public
struct FeatureBase<F: Feature>
{
    /// Convenience helper to access associated feature type directly
    /// (for more expressive and readable code at call site).
    public
    static
    var feature: F.Type
    {
        F.self
    }
    
    /// Convenience shortcut returning same as `feature`.
    public
    static
    var ftr: F.Type
    {
        feature
    }
    
    private
    let dispatcher: Dispatcher
    
    public
    init(with dispatcher: Dispatcher)
    {
        self.dispatcher = dispatcher
    }
}

// MARK: - Transactions

public
extension FeatureBase
{
    /// Transaction helper that re-throws any errors that happen
    /// during `handler` execution, also `TransactonError` will
    /// cause critical error in `DEBUG` mode only.
    @discardableResult
    func execute<T>(
        scope: String = #file,
        context: String = #function,
        location: Int = #line,
        _ handler: (inout TransactionContext<F>) throws -> T
    ) throws -> T {
        
        do
        {
            return try dispatcher
                .transact(
                    scope: scope,
                    context: context,
                    location: location,
                    handler
                )
                .get()
        }
        catch let error as Dispatcher.TransactonError
        {
            /// only rise as critical `TransactonError`
            
            #if DEBUG

            assertionFailure("❌ [UniFlow] Transaction failed: \(error)")

            #endif
            
            throw error
        }
        catch
        {
            throw error
        }
    }
    
    /// Transaction within `handler` must be successful,
    /// or a critical error will be thrown (in `DEBUG` mode only).
    @discardableResult
    func must<T>(
        scope: String = #file,
        context: String = #function,
        location: Int = #line,
        _ handler: (inout TransactionContext<F>) throws -> T
    ) -> Result<T, Error> {
        
        do
        {
            return try .success(
                dispatcher
                    .transact(
                        scope: scope,
                        context: context,
                        location: location,
                        handler
                    )
                    .get()
            )
        }
        catch /// catch and rise as critical any error
        {
            #if DEBUG

            assertionFailure("❌ [UniFlow] Transaction failed: \(error)")

            #endif
            
            return .failure(error) // just a fallback for non-DEBUG
        }
    }
    
    /// Transaction within `handler` may fail,
    /// but failure is an acceptable outcome,
    /// so no errors will be thrown, but the
    /// action will be rejected.
    @discardableResult
    func should<T>(
        scope: String = #file,
        context: String = #function,
        location: Int = #line,
        _ handler: (inout TransactionContext<F>) throws -> T
    ) -> Result<T, Error> {
        
        do
        {
            return try dispatcher
                .transact(
                    scope: scope,
                    context: context,
                    location: location,
                    handler
                )
        }
        catch /// only expect `TransactonError` here
        {
            #if DEBUG

            assertionFailure("❌ [UniFlow] Transaction failed: \(error)")

            #endif
            
            return .failure(error)
        }
    }
}
