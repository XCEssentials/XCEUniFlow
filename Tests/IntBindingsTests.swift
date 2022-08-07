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

class IntBindingsTests: XCTestCase
{
    var dispatcher: Dispatcher!

    override
    func setUp()
    {
        dispatcher = .init()
    }

    override
    func tearDown()
    {
        dispatcher = nil
    }
}

// MARK: - Tests

extension IntBindingsTests
{
    func test_bindingsOrder()
    {
        // GIVEN
        
        final
        class SUT: FeatureBase, SomeInternalObserver
        {
            static
            var expectInitialization: XCTestExpectation!
            
            static
            var expectTransition: XCTestExpectation!
            
            static
            var expectDeinitialization: XCTestExpectation!
            
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
                dispatcher.must {
                    
                    try initialize(with: One())
                }
            }
            
            func proceed()
            {
                dispatcher.must {
                    
                    try transition(from: One.self, into: Two())
                }
            }
            
            func finish()
            {
                dispatcher.must {
                    
                    try deinitialize(from: Two.self)
                }
            }
            
            static
            var bindings: [InternalBinding]
            {[
                scenario()
                    .when(InitializationInto<One>.done)
                    .then { _ in expectInitialization.fulfill() },
                
                scenario()
                    .when(TransitionBetween<One, Two>.done)
                    .then { _ in expectTransition.fulfill() },
                
                scenario()
                    .when(DeinitializationFrom<Two>.done)
                    .then { _ in expectDeinitialization.fulfill() }
            ]}
        }
        
        SUT.expectInitialization = expectation(description: "Initialization")
        SUT.expectTransition = expectation(description: "Transition")
        SUT.expectDeinitialization = expectation(description: "Deinitialization")
        
        let sut = SUT(with: dispatcher)
        
        // WHEN
        
        sut.start()
        sut.proceed()
        sut.finish()
        
        // THEN
        
        wait(
            for: [
                SUT.expectInitialization,
                SUT.expectTransition,
                SUT.expectDeinitialization
            ],
            timeout: 1,
            enforceOrder: true
        )
    }
}
