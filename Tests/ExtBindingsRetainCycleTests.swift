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

class ExtBindingsRetainCycleTests: XCTestCase
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

extension ExtBindingsRetainCycleTests
{
    func test_observer_withoutBindings()
    {
        // GIVEN

        final
        class Observer
        {
            static
            var expectDeinitialization: XCTestExpectation!
            
            deinit
            {
                Self.expectDeinitialization.fulfill()
            }
        }
        
        //---
        
        var observer: Observer! = Observer()
        
        Observer.expectDeinitialization = expectation(description: "Deinit")
        
        // WHEN
        
        _ = observer
        observer = nil
        
        // THEN

        waitForExpectations(timeout: 1)
    }
    
    func test_observer_withEmptyBindings()
    {
        // GIVEN

        final
        class Observer: SomeExternalObserver
        {
            static
            var expectDeinitialization: XCTestExpectation!
            
            deinit
            {
                Self.expectDeinitialization.fulfill()
            }
            
            let bindings: [ExternalBinding] = []
        }
        
        //---
        
        var observer: Observer! = Observer()
        
        Observer.expectDeinitialization = expectation(description: "Deinit")
        
        // WHEN
        
        _ = observer
        observer = nil
        
        // THEN

        waitForExpectations(timeout: 1)
    }
    
    func test_observer_usingProvidedSourceRef_withoutSubscribing()
    {
        // GIVEN

        final
        class SUT: FeatureBase
        {
            struct One: SomeState { typealias Feature = SUT }
        }

        final
        class Observer: SomeExternalObserver
        {
            static
            var expectDeinitialization: XCTestExpectation!

            var value: String?

            deinit
            {
                Self.expectDeinitialization.fulfill()
            }

            var bindings: [ExternalBinding]
            {[
                scenario()
                    .when(InitializationInto<SUT.One>.done)
                    .then { $0.value = "1" }
            ]}
        }

        //---

        var observer: Observer! = Observer()

        Observer.expectDeinitialization = expectation(description: "Deinit")

        // WHEN

        _ = observer
        observer = nil

        // THEN

        waitForExpectations(timeout: 1)
    }
    
    func test_observer_usingProvidedSourceRef_storingBindings_withoutSubscribing()
    {
        // GIVEN

        final
        class SUT: FeatureBase
        {
            struct One: SomeState { typealias Feature = SUT }
        }

        final
        class Observer: SomeExternalObserver
        {
            static
            var expectDeinitialization: XCTestExpectation!

            var value: String?

            deinit
            {
                Self.expectDeinitialization.fulfill()
            }

            lazy
            var bindings: [ExternalBinding] = [
                
                scenario()
                    .when(InitializationInto<SUT.One>.done)
                    .then { $0.value = "1" }
            ]
        }

        //---

        var observer: Observer! = Observer()

        Observer.expectDeinitialization = expectation(description: "Deinit")

        // WHEN

        _ = observer
        observer = nil

        // THEN

        waitForExpectations(timeout: 1)
    }
    
    func test_observer_usingProvidedSourceRef_withSubscribing()
    {
        // GIVEN

        final
        class SUT: FeatureBase
        {
            struct One: SomeState { typealias Feature = SUT }
        }
        
        final
        class Observer: SomeExternalObserver
        {
            static
            var expectDeinitialization: XCTestExpectation!
            
            var value: String?
            
            deinit
            {
                Self.expectDeinitialization.fulfill()
            }
            
            var bindings: [ExternalBinding]
            {[
                scenario()
                    .when(InitializationInto<SUT.One>.done)
                    .then { $0.value = "1" }
            ]}
        }
        
        //---
        
        var observer: Observer! = Observer()
        
        Observer.expectDeinitialization = expectation(description: "Deinit")
        
        dispatcher.subscribe(observer)
        
        // WHEN
        
        _ = observer
        observer = nil
        
        // THEN

        waitForExpectations(timeout: 1)
    }
    
    func test_observer_usingProvidedSourceRef_storingBindings_withSubscribing()
    {
        // GIVEN

        final
        class SUT: FeatureBase
        {
            struct One: SomeState { typealias Feature = SUT }
        }
        
        final
        class Observer: SomeExternalObserver
        {
            static
            var expectDeinitialization: XCTestExpectation!
            
            var value: String?
            
            deinit
            {
                Self.expectDeinitialization.fulfill()
            }
            
            lazy
            var bindings: [ExternalBinding] = [
                
                scenario()
                    .when(InitializationInto<SUT.One>.done)
                    .then { $0.value = "1" }
            ]
        }
        
        //---
        
        var observer: Observer! = Observer()
        
        Observer.expectDeinitialization = expectation(description: "Deinit")
        
        dispatcher.subscribe(observer)
        
        // WHEN
        
        _ = observer
        observer = nil
        
        // THEN

        waitForExpectations(timeout: 1)
    }
    
    func test_observer_usingDirectSelfRef_withoutSubscribing()
    {
        // GIVEN

        final
        class SUT: FeatureBase
        {
            struct One: SomeState { typealias Feature = SUT }
        }

        final
        class Observer: SomeExternalObserver
        {
            static
            var expectDeinitialization: XCTestExpectation!

            var value: String?

            deinit
            {
                Self.expectDeinitialization.fulfill()
            }

            var bindings: [ExternalBinding]
            {[
                scenario()
                    .when(InitializationInto<SUT.One>.done)
                    .then { _ in self.value = "2" }
            ]}
        }

        //---

        var observer: Observer! = Observer()

        Observer.expectDeinitialization = expectation(description: "Deinit")

        // WHEN

        _ = observer
        observer = nil

        // THEN

        waitForExpectations(timeout: 1)
    }
    
    func test_observer_usingDirectSelfRef_storingBindings_withoutSubscribing()
    {
        // GIVEN

        final
        class SUT: FeatureBase
        {
            struct One: SomeState { typealias Feature = SUT }
        }

        final
        class Observer: SomeExternalObserver
        {
            static
            var expectDeinitialization: XCTestExpectation!

            var value: String?

            deinit
            {
                Self.expectDeinitialization.fulfill()
            }

            lazy
            var bindings: [ExternalBinding] = [
                
                scenario()
                    .when(InitializationInto<SUT.One>.done)
                    .then { _ in self.value = "2" }
            ]
        }

        //---

        var observer: Observer! = Observer()

        Observer.expectDeinitialization = expectation(description: "Deinit")

        // WHEN

        _ = observer
        observer = nil

        // THEN

        waitForExpectations(timeout: 1)
    }
    
    func test_observer_usingDirectSelfRef_withSubscribing()
    {
        // GIVEN

        final
        class SUT: FeatureBase
        {
            struct One: SomeState { typealias Feature = SUT }
        }
        
        final
        class Observer: SomeExternalObserver
        {
            static
            var expectDeinitialization: XCTestExpectation!
            
            var value: String?
            
            deinit
            {
                Self.expectDeinitialization.fulfill()
            }
            
            var bindings: [ExternalBinding]
            {[
                scenario()
                    .when(InitializationInto<SUT.One>.done)
                    .then { _ in self.value = "2" }
            ]}
        }
        
        //---
        
        var observer: Observer! = Observer()
        
        Observer.expectDeinitialization = expectation(description: "Deinit")
        
        dispatcher.subscribe(observer)
        
        // WHEN
        
        _ = observer
        observer = nil
        
        // THEN

        waitForExpectations(timeout: 1)
    }
    
    func test_observer_usingDirectSelfRef_storingBindings_withSubscribing()
    {
        // GIVEN

        final
        class SUT: FeatureBase
        {
            struct One: SomeState { typealias Feature = SUT }
        }
        
        final
        class Observer: SomeExternalObserver
        {
            static
            var expectDeinitialization: XCTestExpectation!
            
            var value: String?
            
            deinit
            {
                Self.expectDeinitialization.fulfill()
            }
            
            lazy
            var bindings: [ExternalBinding] = [
                
                scenario()
                    .when(InitializationInto<SUT.One>.done)
                    .then { _ in self.value = "2" }
            ]
        }
        
        //---
        
        var observer: Observer! = Observer()
        
        Observer.expectDeinitialization = expectation(description: "Deinit")
        
        dispatcher.subscribe(observer)
        
        // WHEN
        
        _ = observer
        observer = nil
        
        // THEN

        waitForExpectations(timeout: 1)
    }
}
