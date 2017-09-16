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
extension Given.Connector where GivenOutput == Void
{
    func then(
        _ specification: String,
        _ handler: @escaping (@escaping SubmitAction) -> Void
        ) -> Scenario
    {
        typealias Input = GivenOutput
        
        //---
        
        return Scenario(
            when: when,
            given: previousClauses,
            then: Then(specification) { submit, _ in
                
                handler(submit)
            }
        )
    }
}

//===

public
extension Given.Connector
{
    func then(
        _ specification: String,
        _ handler: @escaping (@escaping SubmitAction, GivenOutput) -> Void
        ) -> Scenario
    {
        typealias Input = GivenOutput
        
        //---
        
        return Scenario(
            when: when,
            given: previousClauses,
            then: Then(specification) { submit, previousResult in
                
                let typedPreviousResult =
                
                try Require("Previous result is of type \(Input.self)").isNotNil(
                    
                    previousResult as? Input
                )
                
                //===
                
                handler(submit, typedPreviousResult)
            }
        )
    }
    
    //===
    
    func then(_ specification: String, submit action: Action) -> Scenario
    {
        return Scenario(
            when: when,
            given: previousClauses,
            then: Then(specification) { (submit, _: Any) in

                submit << action
            }
        )
    }

    //===

    func then(_ specification: String, submit actions: [Action]) -> Scenario
    {
        return Scenario(
            when: when,
            given: previousClauses,
            then: Then(specification) { (submit, _: Any) in

                submit << actions
            }
        )
    }
}
