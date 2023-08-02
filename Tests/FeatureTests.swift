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

final
class FeatureA: Feature
{
    struct StateA1: FeatureState
    {
        typealias ParentFeature = FeatureA
        
        let val1: String
    }

    func action1()
    {
        should {
            
            try $0.initialize(with: StateA1(val1: "111"))
        }
    }
}

//---

class FeatureTests: XCTestCase {}

// MARK: - Tests

extension FeatureTests
{
    func test_featureName() throws
    {
        XCTAssertTrue(FeatureA.name.contains("FeatureA"))
        XCTAssertTrue(FeatureA.displayName.contains("FeatureA"))
    }

    func test_featureDisplayName_custom() throws
    {
        final
        class FeatureB: Feature, WithCustomDisplayName
        {
            static
            let customDisplayName = "CustomDisplayName"
        }

        XCTAssertTrue(FeatureB.name.contains("FeatureB"))
        XCTAssertEqual(FeatureB.displayName, "CustomDisplayName")
    }
    
    @MainActor
    func test_action()
    {
        let disp = Dispatcher()
        
        //---
        
        FeatureA(with: disp).action1()
        let state = disp.storage[FeatureA.StateA1.self]!
        
        //---
        
        XCTAssertEqual(state.val1, "111")
        XCTAssertEqual(disp.storage[\FeatureA.StateA1.val1], "111")
    }
}
