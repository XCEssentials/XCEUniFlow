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

import XCERequirement

//===

public
struct Scenario
{
    let when: When
    let given: [Given]
    let then: Then
}

// MARK: - MIddleware builder

extension Scenario
{
    var asMiddleware: Dispatcher.Middleware
    {
        return { globalModel, mutation, submit in
            
            var input: Any? =
            
            try Require(self.when.specification).isNotNil(
            
                self.when.implementation(mutation)
            )
            
            //---
            
            for item in self.given
            {
                guard
                    let givenInput = input
                else
                {
                    break
                }

                //---

                input = try item.implementation(globalModel, givenInput)
            }

            //--

            guard
                let thenInput = input
            else
            {
                return
            }

            //--

            self.then.implementation(submit, thenInput)
        }
    }
}
