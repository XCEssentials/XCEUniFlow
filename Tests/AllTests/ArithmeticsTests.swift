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
import SwiftHamcrest

@testable
import XCEUniFlow

//---

class ArithmeticsTests: XCTestCase
{
    func testBeginPositive()
    {
        let state = GlobalModel()

        //---

        do
        {
            try Arithmetics
                .begin()
                .perform(with: state)
                ./ InitializationInto<Arithmetics.Main>.init
                .* { assertThat($0, not(nilValue()))  }
        }
        catch
        {
            XCTFail("\(error)")
        }
    }

    func testBeginNegative()
    {
        let state = GlobalModel()
            .store(Arithmetics.Main(val: 1))

        //---

        do
        {
            _ = try Arithmetics
                .begin()
                .perform(with: state)

            //---

            XCTFail("Should never come to this point")
        }
        catch
        {
            // failed as expected
        }
    }

    func testSetExplicitPositive()
    {
        let sourceValue = Int(arc4random_uniform(10000))
        let targetValue = sourceValue + 1 + Int(arc4random_uniform(100))

        let state = GlobalModel()
            .store(Arithmetics.Main(val: sourceValue))

        //---

        do
        {
            try Arithmetics
                .setExplicit(value: targetValue)
                .perform(with: state)
                ./ ActualizationIn<Arithmetics.Main>.init
                ./ { $0!.state.val }
                .* { assertThat($0, equalTo(targetValue)) }
        }
        catch
        {
            XCTFail("\(error)")
        }
    }

    func testSetExplicitNegativeUninitialized()
    {
        let state = GlobalModel()

        //---

        do
        {
            _ = try Arithmetics
                .setExplicit(value: Int(arc4random_uniform(10000)))
                .perform(with: state)

            //---

            XCTFail("Should never come to this point")
        }
        catch UniFlowError.featureIsNotInState(let feature, _, _)
        {
            assertThat(feature.name, equalTo(XCEUniFlowAllTests.Arithmetics.name))
        }
        catch
        {
            XCTFail("Should never come to this point")
        }
    }

    func testSetExplicitNegativeSameValue()
    {
        let theValue = Int(arc4random_uniform(10000))

        let state = GlobalModel()
            .store(Arithmetics.Main(val: theValue))

        //---

        do
        {
            _ = try Arithmetics
                .setExplicit(value: theValue)
                .perform(with: state)

            //---

            XCTFail("Should never come to this point")
        }
        catch _ as UnsatisfiedRequirement
        {
            // okay
        }
        catch
        {
            XCTFail("Should never come to this point")
        }
    }
}
