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
struct Requirement
{
    public
    let what: String
    
    public
    init(_ what: String)
    {
        self.what = what
    }
}

public
typealias Require = Requirement

public
typealias REQ = Requirement

// MARK: - Errors

public
struct UnFulfilledRequirement: Error, CustomStringConvertible
{
    public
    let description: String
    
    init(_ requirement: String)
    {
        self.description = "[\(requirement)] requirement was NOT fulfilled."
    }
}

// MARK: - Verifications

public
extension Require
{
    @discardableResult
    func isNotNil<Output>(_ value: Output?) throws -> Output
    {
        guard
            let result = value
        else
        {
            throw UnFulfilledRequirement(what)
        }
        
        //---
        
        return result
    }
    
    //===
    
    @discardableResult
    func isNotNil<Output>(_ body: () throws -> Output?) throws -> Output
    {
        guard
            let result = try body()
        else
        {
            throw UnFulfilledRequirement(what)
        }
        
        //---
        
        return result
    }
    
    //===
    
    func isNil(_ value: Any?) throws
    {
        guard
            value == nil
        else
        {
            throw UnFulfilledRequirement(what)
        }
    }
    
    //===
    
    func isNil(_ body: () throws -> Any?) throws
    {
        guard
            try body() == nil
        else
        {
            throw UnFulfilledRequirement(what)
        }
    }
    
    //===
    
    func isTrue(_ value: Bool) throws
    {
        guard
            value
        else
        {
            throw UnFulfilledRequirement(what)
        }
    }
    
    //===
    
    func isTrue(_ body: () throws -> Bool) throws
    {
        guard
            try body()
        else
        {
            throw UnFulfilledRequirement(what)
        }
    }
    
    //===
    
    func isFalse(_ value: Bool) throws
    {
        guard
            !value
        else
        {
            throw UnFulfilledRequirement(what)
        }
    }
    
    //===
    
    func isFalse(_ body: () throws -> Bool) throws
    {
        guard
            try !body()
        else
        {
            throw UnFulfilledRequirement(what)
        }
    }
}
