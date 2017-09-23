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
extension Given.ModelConnector where GivenOutput == Void
{
    func then(
        _ specification: String,
        do handler: @escaping (@escaping SubmitAction) -> Void
        ) -> ModelBinding
    {
        return ModelBinding(
            context: scenario.context,
            summary: scenario.summary,
            when: when,
            given: previousClauses,
            then: ModelBinding.Then(specification) { submit, _ in
                
                handler(submit)
            }
        )
    }
}

//===

public
extension Given.ModelConnector
{
    func then(
        _ specification: String,
        do handler: @escaping (@escaping SubmitAction, GivenOutput) -> Void
        ) -> ModelBinding
    {
        typealias Input = GivenOutput
        
        //---
        
        return ModelBinding(
            context: scenario.context,
            summary: scenario.summary,
            when: when,
            given: previousClauses,
            then: ModelBinding.Then(specification) { submit, previousResult in
                
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
    
    func then(
        _ specification: String,
        submit actionGetter: @escaping (GivenOutput) -> Action
        ) -> ModelBinding
    {
        typealias Input = GivenOutput
        
        //---
        
        return ModelBinding(
            context: scenario.context,
            summary: scenario.summary,
            when: when,
            given: previousClauses,
            then: ModelBinding.Then(specification) { submit, previousResult in
                
                let typedPreviousResult =
                    
                try Require("Previous result is of type \(Input.self)").isNotNil(
                    
                    previousResult as? Input
                )
                
                //===
                
                submit << actionGetter(typedPreviousResult)
            }
        )
    }

    //===
    
    func then(
        _ specification: String,
        submit actionGetter: @escaping () -> Action
        ) -> ModelBinding
    {
        return ModelBinding(
            context: scenario.context,
            summary: scenario.summary,
            when: when,
            given: previousClauses,
            then: ModelBinding.Then(specification) { submit, _ in
                
                submit << actionGetter
            }
        )
    }

    //===
    
    func then(_ specification: String, submit action: Action) -> ModelBinding
    {
        return ModelBinding(
            context: scenario.context,
            summary: scenario.summary,
            when: when,
            given: previousClauses,
            then: ModelBinding.Then(specification) { submit, _ in

                submit << action
            }
        )
    }

    //===

    func then(_ specification: String, submit actions: [Action]) -> ModelBinding
    {
        return ModelBinding(
            context: scenario.context,
            summary: scenario.summary,
            when: when,
            given: previousClauses,
            then: ModelBinding.Then(specification) { submit, _ in

                submit << actions
            }
        )
    }
}
