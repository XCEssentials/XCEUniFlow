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

@testable
import XCEUniFlow

//---

class ArithmeticsTests: XCTestCase
{
    typealias SUT = Arithmetics
    
    var dispatcher: Dispatcher!
    var sut: Arithmetics!
    
    override
    func setUp()
    {
        dispatcher = .init()
        sut = Arithmetics(with: dispatcher)
        
        //---
        
        XCTAssertEqual(sut.dispatcher.allFeatures.count, 0)
        XCTAssertEqual(sut.dispatcher.allStates.count, 0)
    }
    
    override
    func tearDown()
    {
        dispatcher = nil
        sut = nil
    }
}

// MARK: - Tests

extension ArithmeticsTests
{
    func test_accessLog_reportsImmediately()
    {
        // GIVEN
        
        let expect1 = expectation(description: "Rejection report")
        let expect2 = expectation(description: "Continue after triggering action")
        
        let sub = dispatcher
            .accessLog
            .onRejected
            .sink { _ in
                
                expect1.fulfill()
            }
        
        _ = sub // silence warning
        
        // WHEN
        
        sut.incFive() // expect to FAIL, cause we didn't initialize yet
        expect2.fulfill()
        
        // THEN
        
        XCTAssertFalse(SUT.isPresent(in: dispatcher))
        wait(for: [expect1, expect2], timeout: 1, enforceOrder: true)
    }
    
    func test_initialization_success() throws
    {
        let input = SUT.Main(val: 0)
        
        try dispatcher.startTransaction(
            scope: #file,
            context: #function,
            location: #line
        )
        
        try sut.initialize(with: input)
        
        let report = try dispatcher.commitTransaction(
            scope: #file,
            context: #function,
            location: #line
        )
        
        //---
        
        guard
            case .processed(let mutations) = report.outcome
        else
        {
            return XCTFail("Unexpected failure: \(report.outcome)")
        }
        
        XCTAssertEqual(mutations.count, 1)
        
        guard
            case let .initialization(newValue) = mutations[0].operation
        else
        {
            return XCTFail("Unexpected operation: \(mutations[0].operation)")
        }
        
        XCTAssert(type(of: newValue).feature is SUT.Type)
        XCTAssertEqual((newValue as! SUT.Main).val, 0)
    }
    
    func test_initialization_fails_ifAlreadyInitialized() throws
    {
        let input = SUT.Main(val: 0)
        
        try dispatcher.startTransaction(
            scope: #file,
            context: #function,
            location: #line
        )
        
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
                case Dispatcher.AccessError.failureDuringAccess(_, _, let wrappedError) = error,
                let semanticError = wrappedError as? ExpectedMutation.SemanticError
            else
            {
                return XCTFail("Unexpected failure type: \(error)")
            }
            
            guard
                case .initialization = semanticError.expectedMutation
            else
            {
                return XCTFail("Unexpected `expectedMutation`: \(semanticError.expectedMutation)")
            }
            
            guard
                case let .actualization(oldValue, newValue) = semanticError.proposedOutcome
            else
            {
                return XCTFail("Unexpected `proposedOutcome`: \(semanticError.proposedOutcome)")
            }
            
            XCTAssert(type(of: newValue).feature is SUT.Type)
            XCTAssertEqual((oldValue as! SUT.Main).val, 0)
            XCTAssertEqual((newValue as! SUT.Main).val, 0)
        }
    }

    func test_begin_success() throws
    {
        sut.begin()
        
        //---
        
        XCTAssertEqual(sut.dispatcher.allFeatures.count, 1)
        XCTAssertEqual(sut.dispatcher.allStates.count, 1)
        XCTAssert(sut.dispatcher.allFeatures[0] is SUT.Type)
        XCTAssert(sut.dispatcher.allStates[0] is SUT.Main)
        XCTAssertEqual((sut.dispatcher.allStates[0] as! SUT.Main).val, 0)
    }
    
    func test_begin_doubleCallHasNoEffect() throws
    {
        sut.begin()
        sut.begin(with: 5) // repeating call causes no effect on the state
        
        //---
        
        XCTAssertEqual(sut.dispatcher.allFeatures.count, 1)
        XCTAssertEqual(sut.dispatcher.allStates.count, 1)
        XCTAssert(sut.dispatcher.allFeatures[0] is SUT.Type)
        XCTAssert(sut.dispatcher.allStates[0] is SUT.Main)
        XCTAssertEqual((sut.dispatcher.allStates[0] as! SUT.Main).val, 0)
    }
    
    func test_setExplicit_success() throws
    {
        sut.begin(with: 0)
        sut.setExplicit(value: 5)

        //---

        XCTAssertEqual(sut.dispatcher.allFeatures.count, 1)
        XCTAssertEqual(sut.dispatcher.allStates.count, 1)
        XCTAssert(sut.dispatcher.allFeatures[0] is SUT.Type)
        XCTAssert(sut.dispatcher.allStates[0] is SUT.Main)
        XCTAssertEqual((sut.dispatcher.allStates[0] as! SUT.Main).val, 5)
    }
    
    func test_setExplicit_noEffectIfUninitialized() throws
    {
        sut.setExplicit(value: 5)

        //---

        XCTAssertEqual(sut.dispatcher.allFeatures.count, 0)
        XCTAssertEqual(sut.dispatcher.allStates.count, 0)
    }
    
    func test_setExplicit_noEffectIfPreconditionFails() throws
    {
        sut.begin(with: 0)
        sut.setExplicit(value: 0) // this will not cause any mutation

        //---

        XCTAssertEqual(sut.dispatcher.allFeatures.count, 1)
        XCTAssertEqual(sut.dispatcher.allStates.count, 1)
        XCTAssert(sut.dispatcher.allFeatures[0] is SUT.Type)
        XCTAssert(sut.dispatcher.allStates[0] is SUT.Main)
        XCTAssertEqual((sut.dispatcher.allStates[0] as! SUT.Main).val, 0)
    }
}
