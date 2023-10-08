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
    typealias SUT = CurrentSession
    
    var dispatcher: Dispatcher!
    var sut: SUT!
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
    func test_initialization_viaAction_OK()
    {
        // GIVEN
        
        XCTAssertFalse(dispatcher.storage.hasFeature(SUT.self))
        XCTAssertFalse(dispatcher.storage.hasState(ofType: SUT.Anon.self))
        
        // WHEN
        
        sut.prepare()

        // THEN
        
        XCTAssertTrue(dispatcher.storage.hasFeature(SUT.self))
        XCTAssertTrue(dispatcher.storage.hasState(ofType: SUT.Anon.self))
    }
    
    func test_initialization_inline_OK()
    {
        // GIVEN
        
        XCTAssertFalse(dispatcher.storage.hasFeature(SUT.self))
        XCTAssertFalse(dispatcher.storage.hasState(ofType: SUT.Anon.self))
        
        // WHEN
        
        sut.should {
            
            try $0.initialize(with: SUT.Anon())
        }

        // THEN
        
        XCTAssertTrue(dispatcher.storage.hasFeature(SUT.self))
        XCTAssertTrue(dispatcher.storage.hasState(ofType: SUT.Anon.self))
    }
    
    func test_initialization_FAILS_if_repeat()
    {
        // GIVEN
        
        /// the feature has NOT been initialized yet,
        /// hence it's NOT present in the `storage`:
        XCTAssertFalse(dispatcher.storage.hasFeature(SUT.self))
        
        // WHEN
        
        sut.should {

            try $0.initialize(with: SUT.Anon())
            
            /// so far everythign is fine, the mutation above has affected
            /// the `storage`, so it temporary HAS the feature/state:
            XCTAssertTrue(dispatcher.storage.hasState(ofType: SUT.Anon.self))
            
            //---
            
            /// NOTE: the below line would trigger `fatalError`,
            /// because nested transactions are NOT allowed as they lead to
            /// abbigous behavior:
            //sut.prepare() // ❌
            
            // this will interrupt execution and reject whole transaction:
            try $0.initialize(with: SUT.Anon()) // ❌
            
            /// Execution does NOT proceed after the line above,
            /// since it has thrown an error and whole transaction
            /// is going to be rejected and any mutations that have
            /// alredy been made will be reverted, the whole `storage`
            /// in `dispatcher` will be reset to pre-transaction snapshot.
            
            XCTFail("Must not reach this point!")
        }
        
        // THEN
        
        /// AFTER we exit transaction scope - the `storage` is intact,
        /// same as it BEFORE the transaction has been started:
        XCTAssertFalse(dispatcher.storage.hasFeature(SUT.self))
    }
    
    func test_transition() async
    {
        // GIVEN
        
        let loggedIn = expectation(description: "LoggedIn")
        
        dispatcher
            .on(TransitionBetween<SUT.LoggingIn, SUT.LoggedIn>.done)
            .sink { _ in loggedIn.fulfill() }
            .store(in: &subs)
        
        XCTAssertFalse(dispatcher.storage.hasFeature(SUT.self))
        XCTAssertFalse(dispatcher.storage.hasState(ofType: SUT.Anon.self))
        
        // WHEN
        
        sut.prepare()
        sut.login(username: "joe", password: "111")

        // THEN
        
        XCTAssertTrue(dispatcher.storage.hasFeature(SUT.self))
        XCTAssertTrue(dispatcher.storage.hasState(ofType: SUT.LoggingIn.self))
        XCTAssertEqual(dispatcher.storage[\SUT.LoggingIn.username], "joe")
        
        await fulfillment(of: [loggedIn])
        
        XCTAssertTrue(dispatcher.storage.hasState(ofType: SUT.LoggedIn.self))
        XCTAssertEqual(dispatcher.storage[\SUT.LoggedIn.sessionToken], "123")
    }
}
