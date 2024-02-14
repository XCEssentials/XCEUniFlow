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

/// Base implementation for a feature. Subclass this class with a `final` class
/// to declare custom feature.
///
/// NOTE: for better developer experience, feature is an open class
/// with built-in storage for `dispatcher` that enables access to transaction
/// helpers from within this feature. However, avoid adding any stored
/// properties in custom features (subclasses of this class) to avoid any side
/// effects. Feature is supposed to be merely a shell around `dispatcher` encapsulating
/// business logic, all stored values must be stored in various feature states inside
/// `dispatcher` and retreived from there on demand.
@MainActor
open
class Feature
{
    private
    let dispatcher: Dispatcher
    
    public
    init(with dispatcher: Dispatcher)
    {
        self.dispatcher = dispatcher
    }
}

// MARK: - Info

public
extension Feature
{
    /// `Storage` will use this as actual key.
    nonisolated
    static
    var name: String
    {
        // full type name, including enclosing types for nested declarations:
        return .init(reflecting: Self.self)
    }
    
    /// Convenience helper that determines user-friendly feature name.
    nonisolated
    static
    var displayName: String
    {
        if
            let customizedSelf = Self.self as? any WithCustomDisplayName.Type
        {
            return customizedSelf.customDisplayName
        }
        else
        {
            return Self
                .name
                .split(separator: ".")
                .dropFirst() // drop app/module name
                .joined(separator: ".")
                .split(separator: ":")
                .last
                .map(String.init) ?? ""
        }
    }
}

// MARK: - Transactions

public
extension Feature
{
    /// Transaction helper that re-throws any errors that happen
    /// during `handler` execution, `NestedTransactonError` will
    /// cause critical error and stop app execution.
    @discardableResult
    func execute<T>(
        file: StaticString = #file,
        function: StaticString = #function,
        line: UInt = #line,
        _ handler: (inout TransactionContext) throws -> T
    ) throws -> T {
        
        do
        {
            return try dispatcher
                .transact(
                    file: file,
                    function: function,
                    line: line,
                    handler
                )
                .get() /// NOTE: throw `error` from received result
        }
        catch let error as Dispatcher.NestedTransactonError
        {
            fatalError(
                "❌ [UniFlow] Nested transaction is detected: \(error)",
                file: file,
                line: line
            )
        }
        catch
        {
            throw error
        }
    }
    
    /// Transaction within `handler` must be successful,
    /// any error will cause critical error in DEBUG mode,
    /// `NestedTransactonError` will cause critical error
    /// and stop app execution.
    @discardableResult
    func must<T>(
        file: StaticString = #file,
        function: StaticString = #function,
        line: UInt = #line,
        _ handler: (inout TransactionContext) throws -> T
    ) -> Result<T, Error> {
        
        do
        {
            return try .success(
                dispatcher
                    .transact(
                        file: file,
                        function: function,
                        line: line,
                        handler
                    )
                    .get() /// NOTE: throw `error` from received result
            )
        }
        catch let error as Dispatcher.NestedTransactonError
        {
            fatalError(
                "❌ [UniFlow] Nested transaction is detected: \(error)",
                file: file,
                line: line
            )
        }
        catch
        {
            assertionFailure(
                "❌ [UniFlow] Transaction has failed: \(error)",
                file: file,
                line: line
            )
            
            return .failure(error) // fallback for non-DEBUG
        }
    }
    
    /// Transaction within `handler` may fail,
    /// but failure is an acceptable outcome,
    /// so no errors will be thrown, but the
    /// action will be rejected.
    @discardableResult
    func should<T>(
        file: StaticString = #file,
        function: StaticString = #function,
        line: UInt = #line,
        _ handler: (inout TransactionContext) throws -> T
    ) -> Result<T, Error> {
        
        do
        {
            return try dispatcher
                .transact(
                    file: file,
                    function: function,
                    line: line,
                    handler
                ) /// NOTE: non-transaction errors will be wrapped in `Result`
        }
        catch /// we only expect `TransactonError` here
        {
            fatalError(
                "❌ [UniFlow] Nested transaction is detected: \(error)",
                file: file,
                line: line
            )
        }
    }
}
