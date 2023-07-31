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

import Combine

//---

@MainActor
class CurrentSessionTests: XCTestCase
{
    var dispatcher: Dispatcher!
    var sut: CurrentSession!
    var subs: [AnyCancellable] = []
    
    override
    func setUp()
    {
        dispatcher = Dispatcher()
        sut = .init(with: dispatcher)
    }
    
    override
    func tearDown()
    {
        sut = nil
        dispatcher = nil
    }
}

// MARK: - Tests

extension CurrentSessionTests
{
    func test_nestedTransactions_correct()
    {
        sut.should {
            
            /// the below line would trigger `assertionFailure`,
            /// because we are already inside a transaction:
            // sut.prepare() // ❌
            
            try $0.initialize(with: CurrentSession.Anon())
            try $0.transition(into: CurrentSession.LoggingIn(username: "user"))
            XCTAssertEqual(dispatcher.storage[\CurrentSession.LoggingIn.username], "user")
        }
    }
    
    func test_nestedTransactions_incorrect()
    {
        XCTAssertNil(dispatcher.storage[CurrentSession.feature])
        
        sut.should {
        
            XCTAssertNil(dispatcher.storage[CurrentSession.feature])
            try $0.initialize(with: CurrentSession.Anon())
            XCTAssertTrue(dispatcher.storage.hasState(ofType: CurrentSession.Anon.state))
            try $0.initialize(with: CurrentSession.Anon()) // ❌
            XCTFail("Must not reach this point!")
        }
    }
    
    func test_initialization()
    {
        // GIVEN
        
        XCTAssertFalse(dispatcher.storage.hasFeature(CurrentSession.feature))
        XCTAssertFalse(dispatcher.storage.hasState(ofType: CurrentSession.Anon.state))
        
        // WHEN
        
        sut.prepare()

        // THEN
        
        XCTAssertTrue(dispatcher.storage.hasFeature(CurrentSession.feature))
        XCTAssertTrue(dispatcher.storage.hasState(ofType: CurrentSession.Anon.state))
    }
    
    func test_transition() async
    {
        // GIVEN
        
        let loggedIn = expectation(description: "LoggedIn")
        
        dispatcher
            .on(TransitionBetween<CurrentSession.LoggingIn, CurrentSession.LoggedIn>.done)
            .sink { _ in loggedIn.fulfill() }
            .store(in: &subs)
        
        XCTAssertFalse(dispatcher.storage.hasFeature(CurrentSession.feature))
        XCTAssertFalse(dispatcher.storage.hasState(ofType: CurrentSession.Anon.state))
        
        // WHEN
        
        sut.prepare()
        sut.login(username: "joe", password: "111")

        // THEN
        
        XCTAssertTrue(dispatcher.storage.hasFeature(CurrentSession.feature))
        XCTAssertTrue(dispatcher.storage.hasState(ofType: CurrentSession.LoggingIn.state))
        XCTAssertEqual(dispatcher.storage[\CurrentSession.LoggingIn.username], "joe")
        
        await fulfillment(of: [loggedIn])
        
        XCTAssertTrue(dispatcher.storage.hasState(ofType: CurrentSession.LoggedIn.state))
        XCTAssertEqual(dispatcher.storage[\CurrentSession.LoggedIn.sessionToken], "123")
    }
}
