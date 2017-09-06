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

import XCTest

import XCERequirement

//===

public
struct Assertation
{
    public
    let what: String
    
    public
    let file: StaticString
    
    public
    let line: UInt
    
    public
    init(_ what: String, file: StaticString = #file, line: UInt = #line)
    {
        self.what = what
        self.file = file
        self.line = line
    }
    
    fileprivate
    func fail(with error: Error)
    {
        if
            let error = error as? UnFulfilledRequirement
        {
            XCTFail(error.description, file: file, line: line)
        }
        else
        {
            XCTFail(error.localizedDescription, file: file, line: line)
        }
    }
}

public
typealias Assert = Assertation

//===

public
extension Assertation
{
    @discardableResult
    func isNotNil<Output>(_ value: Output?) -> Output?
    {
        do
        {
            return try Require(what).isNotNil(value)
        }
        catch
        {
            fail(with: error)
            
            //---
            
            return nil
        }
    }
    
    //===
    
    @discardableResult
    func isNotNil<Output>(_ body: () throws -> Output?) -> Output?
    {
        do
        {
            return try Require(what).isNotNil(body)
        }
        catch
        {
            fail(with: error)
            
            //---
            
            return nil
        }
    }
    
    //===
    
    func isNil(_ value: Any?)
    {
        do
        {
            return try Require(what).isNil(value)
        }
        catch
        {
            fail(with: error)
        }
    }
    
    //===
    
    func isNil(_ body: () throws -> Any?)
    {
        do
        {
            return try Require(what).isNil(body)
        }
        catch
        {
            fail(with: error)
        }
    }
    
    //===
    
    func isTrue(_ value: Bool)
    {
        do
        {
            return try Require(what).isTrue(value)
        }
        catch
        {
            fail(with: error)
        }
    }
    
    //===
    
    func isTrue(_ body: () throws -> Bool)
    {
        do
        {
            return try Require(what).isTrue(body)
        }
        catch
        {
            fail(with: error)
        }
    }
    
    //===
    
    func isFalse(_ value: Bool)
    {
        do
        {
            return try Require(what).isFalse(value)
        }
        catch
        {
            fail(with: error)
        }
    }
    
    //===
    
    func isFalse(_ body: () throws -> Bool)
    {
        do
        {
            return try Require(what).isFalse(body)
        }
        catch
        {
            fail(with: error)
        }
    }
}
