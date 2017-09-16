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
    
    typealias PreviousResult = Any
    typealias Result = Any
    typealias Handler = (GlobalModel, PreviousResult) throws -> Result
    
    // MARK: - Public types
    
    public
    struct Failed: ScenarioClauseFailure
    {
        public
        let specification: String
        
        public
        let reason: Error
    }
    
    // MARK: - Internal members
    
    let specification: String
    let implementation: Handler
    
    // MARK: - Initializers
    
    init(
        _ specification: String,
        _ implementation: @escaping Handler
        )
    {
        self.specification = specification
        self.implementation = {
            
            do
            {
                return try implementation($0, $1)
            }
            catch
            {
                throw Failed(specification: specification, reason: error)
            }
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
    }
}

//===

public
extension Given.Connector
{
    /**
     Adds subsequent 'GIVEN' clause in Scenario.
     */
    func and<Output>(
        _ specification: String,
        _ handler: @escaping (GlobalModel, GivenOutput) throws -> Output
        ) -> Given.Connector<Output>
    {
        typealias Input = GivenOutput
        
        //---
        
        let nextGiven = Given(specification) { globalModel, previousResult in
            
            let typedPreviousResult =
                
            try Require("Previous result is of type \(Input.self)").isNotNil(
                
                previousResult as? Input
            )
            
            //===
            
            return try handler(globalModel, typedPreviousResult)
        }
        
        //---
        
        var items = self.previousClauses
        items.append(nextGiven)

        //---

        return Given.Connector<Output>(when: when, previousClauses: items)
    }
    
    //===
    
    /**
     Adds subsequent 'GIVEN' clause in Scenario that does NOT return anything.
     */
    func and(
        _ specification: String,
        _ handler: @escaping (GlobalModel, GivenOutput) throws -> Void
        ) -> Given.Connector<Void>
    {
        typealias Input = GivenOutput
        
        //---
        
        let nextGiven = Given(specification) { globalModel, previousResult in
            
            let typedPreviousResult =
                
            try Require("Previous result is of type \(Input.self)").isNotNil(
                
                previousResult as? Input
            )
            
            //===
            
            try handler(globalModel, typedPreviousResult)
            
            //===
            
            return ()
        }
        
        //---
        
        var items = self.previousClauses
        items.append(nextGiven)
        
        //---
        
        return Given.Connector<Void>(when: when, previousClauses: items)
    }
}

// MARK: - Add subsequent GIVEN clauses AFTER one that returns nothing

public
extension Given.Connector where GivenOutput == Void
{
    /**
     Adds subsequent 'GIVEN' clause in Scenario.
     */
    func and<Output>(
        _ specification: String,
        _ handler: @escaping (GlobalModel) throws -> Output
        ) -> Given.Connector<Output>
    {
        let nextGiven = Given(specification) { globalModel, _ in
            
            return try handler(globalModel)
        }
        
        //---
        
        var items = self.previousClauses
        items.append(nextGiven)
        
        //---
        
        return Given.Connector<Output>(when: when, previousClauses: items)
    }
    
    //===
    
    /**
     Adds subsequent 'GIVEN' clause in Scenario that does NOT return anything.
     */
    func and(
        _ specification: String,
        _ handler: @escaping (GlobalModel) throws -> Void
        ) -> Given.Connector<Void>
    {
        let nextGiven = Given(specification) { globalModel, _ in
            
            try handler(globalModel)
            
            //===
            
            return ()
        }
        
        //---
        
        var items = self.previousClauses
        items.append(nextGiven)
        
        //---
        
        return Given.Connector<Void>(when: when, previousClauses: items)
    }
}
