import XCTest

@testable
import XCEUniFlow

//---

class BindingsTests: XCTestCase
{
    var dispatcher: Dispatcher!
    
    var sut: Arithmetics!
    
    override
    func setUpWithError() throws
    {
        dispatcher = .init()
        sut = Arithmetics(with: dispatcher)
        Arithmetics.onInitialization = nil
        Arithmetics.onActualization = nil
    }

    override
    func tearDownWithError() throws
    {
        Arithmetics.onInitialization = nil
        Arithmetics.onActualization = nil
        sut = nil
        dispatcher = nil
    }
}

// MARK: - Tests

extension BindingsTests
{
    func test_initialization() throws
    {
        // GIVEN
        
        let ex = expectation(description: #function)
        
        Arithmetics.onInitialization = { ex.fulfill() }
        
        // WHEN
        
        sut.begin()
        
        // THEN
        
        waitForExpectations(timeout: 1, handler: nil)
    }

    func test_actualization() throws
    {
        // GIVEN
        
        let ex = expectation(description: #function)
        ex.expectedFulfillmentCount = 2
        
        Arithmetics.onActualization = { ex.fulfill() }
        
        // WHEN
        
        sut.begin()
        sut.incFive()
        sut.incFive()
        
        // THEN
        
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    func test_memoryManagementInBinding()
    {
        // GIVEN
        
        sut = nil
        Arithmetics.resetCounters()
        
        XCTAssertEqual(Arithmetics.initCount, 0)
        XCTAssertEqual(Arithmetics.deinitCount, 0)
        
        sut = Arithmetics(with: dispatcher)
        
        // WHEN
        
        sut.begin()
        sut.incFive()
        sut.incFive()
        
        sut = nil
        
        // THEN
        
        XCTAssertEqual(Arithmetics.initCount, 1)
        XCTAssertEqual(Arithmetics.deinitCount, 1)
    }
}
