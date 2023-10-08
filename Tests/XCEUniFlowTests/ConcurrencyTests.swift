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

fileprivate
final
class M: Feature
{
    struct One: FeatureState
    {
        typealias ParentFeature = M
    }
    
    struct Two: FeatureState
    {
        typealias ParentFeature = M
    }

    func start() throws
    {
        try execute {
            
            try $0.initialize(with: One())
            
            //---
            
            Task {
                
                finish()
            }
        }
    }
    
    func finish()
    {
        must {
            
            try $0.transition(from: One.self, into: Two())
        }
    }
}

//---

@MainActor
class ConcurrencyTests: XCTestCase
{
    var disp: Dispatcher!
    
    private
    var sut: M!
    
    override
    func setUp()
    {
        disp = Dispatcher()
        sut = .init(with: disp)
    }
    
    override
    func tearDown()
    {
        sut = nil
        disp = nil
    }
}

// MARK: - Tests

extension ConcurrencyTests
{
    func test_immedaiteMutation() throws
    {
        // GIVEN:
        
        XCTAssertFalse(disp.storage.hasFeature(M.self))
        
        // WHEN:
        
        try sut.start()
        
        // THEN:
        
        XCTAssertTrue(disp.storage.hasFeature(M.self))
        XCTAssertTrue(disp.storage.hasState(ofType: M.One.self))
        XCTAssertFalse(disp.storage.hasState(ofType: M.Two.self))
    }
    
    func test_asyncMutation() async throws
    {
        // GIVEN:
        
        try sut.start()
        
        XCTAssertTrue(disp.storage.hasState(ofType: M.One.self))
        XCTAssertFalse(disp.storage.hasState(ofType: M.Two.self))
        
        // WHEN:
        
        try await Task.sleep(nanoseconds: 1000)
        
        // THEN:
        
        XCTAssertFalse(disp.storage.hasState(ofType: M.One.self))
        XCTAssertTrue(disp.storage.hasState(ofType: M.Two.self))
    }
    
    func test_asyncMutation_viaAccessLog() async throws
    {
        // GIVEN:
        
        try sut.start()
        
        // WHEN:
        
        _ = await disp
            .on(AnySettingOf<M>.done)
            .values
            .first(where: { $0.newState is M.Two })
        
        // THEN:
        
        XCTAssertFalse(disp.storage.hasState(ofType: M.One.self))
        XCTAssertTrue(disp.storage.hasState(ofType: M.Two.self))
    }
}
