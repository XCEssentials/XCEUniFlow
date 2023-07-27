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
    var sut: ActionContext<CurrentSession>!
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
    func test_initialization()
    {
        // GIVEN
        
        XCTAssertFalse(dispatcher.storage.hasFeature(CurrentSession.self))
        XCTAssertFalse(dispatcher.storage.hasState(ofType: CurrentSession.Anon.self))
        
        // WHEN
        
        sut.prepare()

        // THEN
        
        XCTAssertTrue(dispatcher.storage.hasFeature(CurrentSession.self))
        XCTAssertTrue(dispatcher.storage.hasState(ofType: CurrentSession.Anon.self))
    }
    
    func test_transition() async
    {
        // GIVEN
        
        let loggedIn = dispatcher
            .on(TransitionBetween<CurrentSession.LoggingIn, CurrentSession.LoggedIn>.done)
        
        XCTAssertFalse(dispatcher.storage.hasFeature(CurrentSession.self))
        XCTAssertFalse(dispatcher.storage.hasState(ofType: CurrentSession.Anon.self))
        
        // WHEN
        
        sut.prepare()
        sut.login(username: "joe", password: "111")

        // THEN
        
        XCTAssertTrue(dispatcher.storage.hasFeature(CurrentSession.self))
        XCTAssertTrue(dispatcher.storage.hasState(ofType: CurrentSession.LoggingIn.self))
        XCTAssertEqual(dispatcher.storage[\CurrentSession.LoggingIn.username], "joe")
        
        for await _ in loggedIn.values { break }
        
        XCTAssertTrue(dispatcher.storage.hasState(ofType: CurrentSession.LoggedIn.self))
        XCTAssertEqual(dispatcher.storage[\CurrentSession.LoggedIn.sessionToken], "123")
    }
}
