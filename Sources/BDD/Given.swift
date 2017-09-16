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
struct Given
{
    // MARK: - Intenral types
    
    typealias WhenResult = Any
    typealias Handler = (GlobalModel, WhenResult) throws -> Any?
    
    // MARK: - Public types
    
    public
    typealias SpecializedHandler<Input, Output> = (GlobalModel, Input) throws -> Output?
    
    // MARK: - Internal members
    
    let specification: String
    let implementation: Handler
    
    // MARK: - Initializers=
    
    init<Input, Output>(
        _ specification: String,
        _ handler: @escaping SpecializedHandler<Input, Output>
        )
    {
        self.specification = specification
        
        self.implementation = { globalModel, previousResult in
            
            let typedPreviousResult =
            
            try Require("Previous result is of type \(Input.self)").isNotNil(
                
                previousResult as? Input
            )
            
            //===
            
            return try handler(globalModel, typedPreviousResult)
        }
    }
}

// MARK: - Connector

public
extension Given
{
    struct Connector<GivenOutput>
    {
        let when: When
        let previousClauses: [Given]
        
        //===
        
        /**
         Adds subsequent 'GIVEN' clauses in Scenario.
         */
        func and<Output>(
            _ specification: String,
            _ subsequentHandler: @escaping SpecializedHandler<GivenOutput, Output>
            ) -> Connector<Output>
        {
            var items = self.previousClauses
            items.append(Given(specification, subsequentHandler))
            
            //---
            
            return Connector<Output>(when: when, previousClauses: items)
        }
    }
}
