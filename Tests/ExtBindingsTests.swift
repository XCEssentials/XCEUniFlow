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

@testable
import XCEUniFlow

//---

class ExtBindingsTests: XCTestCase, SomeExternalObserver
{
    var dispatcher: Dispatcher!
    var sut: SUT!
    
    var expectInitialization: XCTestExpectation!
    var expectTransition: XCTestExpectation!
    var expectDeinitialization: XCTestExpectation!
    
    override
    func setUp()
    {
        dispatcher = .init()
        sut = SUT(with: dispatcher)
        dispatcher.subscribe(self)
    }

    override
    func tearDown()
    {
        expectInitialization = nil
        expectTransition = nil
        expectDeinitialization = nil
        
        sut = nil
        dispatcher = nil
    }
}

// MARK: - Nested types

extension ExtBindingsTests
{
    final
    class SUT: FeatureBase
    {
        struct One: SomeState
        {
            typealias Feature = SUT
        }

        struct Two: SomeState
        {
            typealias Feature = SUT
        }
        
        func start()
        {
            must {

                try initialize(with: One())
            }
        }

        func proceed()
        {
            must {

                try transition(from: One.self, into: Two())
            }
        }

        func finish()
        {
            must {

                try deinitialize(from: Two.self)
            }
        }
    }
}

// MARK: - Tests

extension ExtBindingsTests
{
    func bindings() -> [ExternalBinding]
    {[
        scenario()
            .when(InitializationInto<SUT.One>.done)
            .then { self.expectInitialization.fulfill() },

        scenario()
            .when(TransitionBetween<SUT.One, SUT.Two>.done)
            .then { self.expectTransition.fulfill() },

        scenario()
            .when(DeinitializationFrom<SUT.Two>.done)
            .then { self.expectDeinitialization.fulfill() }
    ]}
}

// MARK: - Tests

extension ExtBindingsTests
{
    func test_extBindingsOrder()
    {
        // GIVEN

        expectInitialization = expectation(description: "Initialization")
        expectTransition = expectation(description: "Transition")
        expectDeinitialization = expectation(description: "Deinitialization")

        // WHEN

        sut.start()
        sut.proceed()
        sut.finish()
        
        // THEN

        wait(
            for: [
                expectInitialization,
                expectTransition,
                expectDeinitialization
            ],
            timeout: 1,
            enforceOrder: true
        )
    }
}
