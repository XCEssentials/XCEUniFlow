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

import XCEPipeline
import XCERequirement
import SwiftHamcrest

@testable
import XCEUniFlow

//---

class ArithmeticsTests: XCTestCase
{
    typealias SUT = Arithmetics
    
    var sut: Arithmetics!
    
    override
    func setUp()
    {
        sut = Arithmetics(with: .init())
        
        //---
        
        XCTAssertEqual(sut.dispatcher.allKeys.count, 0)
        XCTAssertEqual(sut.dispatcher.allValues.count, 0)
    }
    
    override
    func tearDown()
    {
        sut = nil
    }
}

// MARK: - Tests

extension ArithmeticsTests
{
    func test_initialization_success() throws
    {
        let input = SUT.Main(val: 0)
        let output = try sut.initialize(with: input)
        
        //---
        
        XCTAssertEqual(output.count, 1)
        
        guard
            case let .initialization(key, newValue) = output[0].outcome
        else
        {
            return XCTFail("Unexpected output: \(output)")
        }
        
        XCTAssert(key is SUT.Type)
        XCTAssertEqual((newValue as! SUT.Main).val, 0)
    }
    
    func test_initialization_fails_ifAlreadyInitialized() throws
    {
        let input = SUT.Main(val: 0)
        try sut.initialize(with: input)
        
        //---
        
        do
        {
            try sut.initialize(with: input)
            XCTFail("Expected to fail double initialization")
        }
        catch
        {
            guard
                let semanticError = error as? SemanticMutationError
            else
            {
                return XCTFail("Unexpected failure type")
            }
            
            guard
                case .initialization = semanticError.expectedMutation
            else
            {
                return XCTFail("Unexpected `expectedMutation`: \(semanticError.expectedMutation)")
            }
            
            guard
                case let .actualization(key, oldValue, newValue) = semanticError.proposedOutcome
            else
            {
                return XCTFail("Unexpected `proposedOutcome`: \(semanticError.proposedOutcome)")
            }
            
            XCTAssert(key is SUT.Type)
            XCTAssertEqual((oldValue as! SUT.Main).val, 0)
            XCTAssertEqual((newValue as! SUT.Main).val, 0)
        }
    }

    func test_begin_success() throws
    {
        sut.begin()
        
        //---
        
        XCTAssertEqual(sut.dispatcher.allKeys.count, 1)
        XCTAssertEqual(sut.dispatcher.allValues.count, 1)
        XCTAssert(sut.dispatcher.allKeys[0] is SUT.Type)
        XCTAssert(sut.dispatcher.allValues[0] is SUT.Main)
        XCTAssertEqual((sut.dispatcher.allValues[0] as! SUT.Main).val, 0)
    }
    
    func test_begin_doubleCallHasNoEffect() throws
    {
        sut.begin()
        sut.begin(with: 5) // repeating call causes no effect on the state
        
        //---
        
        XCTAssertEqual(sut.dispatcher.allKeys.count, 1)
        XCTAssertEqual(sut.dispatcher.allValues.count, 1)
        XCTAssert(sut.dispatcher.allKeys[0] is SUT.Type)
        XCTAssert(sut.dispatcher.allValues[0] is SUT.Main)
        XCTAssertEqual((sut.dispatcher.allValues[0] as! SUT.Main).val, 0)
    }
    
    func test_setExplicit_success() throws
    {
        sut.begin(with: 0)
        sut.setExplicit(value: 5)

        //---

        XCTAssertEqual(sut.dispatcher.allKeys.count, 1)
        XCTAssertEqual(sut.dispatcher.allValues.count, 1)
        XCTAssert(sut.dispatcher.allKeys[0] is SUT.Type)
        XCTAssert(sut.dispatcher.allValues[0] is SUT.Main)
        XCTAssertEqual((sut.dispatcher.allValues[0] as! SUT.Main).val, 5)
    }
    
    func test_setExplicit_noEffectIfUninitialized() throws
    {
        sut.setExplicit(value: 5)

        //---

        XCTAssertEqual(sut.dispatcher.allKeys.count, 0)
        XCTAssertEqual(sut.dispatcher.allValues.count, 0)
    }
    
    func test_setExplicit_noEffectIfPreconditionFails() throws
    {
        sut.begin(with: 0)
        sut.setExplicit(value: 0) // this will not cause any mutation

        //---

        XCTAssertEqual(sut.dispatcher.allKeys.count, 1)
        XCTAssertEqual(sut.dispatcher.allValues.count, 1)
        XCTAssert(sut.dispatcher.allKeys[0] is SUT.Type)
        XCTAssert(sut.dispatcher.allValues[0] is SUT.Main)
        XCTAssertEqual((sut.dispatcher.allValues[0] as! SUT.Main).val, 0)
    }
}