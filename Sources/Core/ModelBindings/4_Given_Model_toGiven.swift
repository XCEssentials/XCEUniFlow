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

import XCEPipeline

// MARK: - After VOID, WITH output

public
extension Given.ModelConnector where GivenOutput == Void
{
    /**
     Adds subsequent 'GIVEN' clause in Scenario.
     */
    func and<Output>(
        _ specification: String,
        mapState handler: @escaping (GlobalModel) throws -> Output
        ) -> Given.ModelConnector<Output>
    {
        let nextGiven = Given(specification) {
            
            globalModel, _ in
            
            //---
            
            return try globalModel
                ./ handler
        }
        
        //---
        
        return Given.ModelConnector<Output>(
            scenario: scenario,
            when: when,
            previousClauses: self.previousClauses + [nextGiven]
        )
    }
}

// MARK: - After VOID, NO output

public
extension Given.ModelConnector where GivenOutput == Void
{
    /**
     Adds subsequent 'GIVEN' clause in Scenario that does NOT return anything.
     */
    func and(
        _ specification: String,
        withState handler: @escaping (GlobalModel) throws -> Void
        ) -> Given.ModelConnector<Void>
    {
        let nextGiven = Given(specification) {
            
            globalModel, _ in
            
            //---
            
            return try globalModel
                ./ handler
        }
        
        //---
        
        return Given.ModelConnector<Void>(
            scenario: scenario,
            when: when,
            previousClauses: self.previousClauses + [nextGiven]
        )
    }
}

// MARK: - After VOID, Returns Bool

public
extension Given.ModelConnector where GivenOutput == Void
{
    /**
     Adds subsequent 'GIVEN' clause in Scenario that does NOT return anything.
     */
    func and(
        _ specification: String,
        ifMapState handler: @escaping (GlobalModel) throws -> Bool
        ) -> Given.ModelConnector<Void>
    {
        let nextGiven = Given(specification) {
            
            globalModel, _ in
            
            //---
            
            return try globalModel
                ./ handler
                ./ Pipeline.throwIfFalse(BDDExecutionError.handlerIndicatedFailure)
        }

        //---

        return Given.ModelConnector<Void>(
            scenario: scenario,
            when: when,
            previousClauses: self.previousClauses + [nextGiven]
        )
    }
}

// MARK: - WITH output

public
extension Given.ModelConnector
{
    /**
     Adds subsequent 'GIVEN' clause in Scenario.
     */
    func and<Output>(
        _ specification: String,
        mapInput handler: @escaping (GivenOutput) throws -> Output
        ) -> Given.ModelConnector<Output>
    {
        typealias Input = GivenOutput
        
        //---
        
        let nextGiven = Given(specification) {
            
            _, previousResult in
            
            //---
            
            return try previousResult
                ./ { $0 as? Input }
                ./ { (try $0 ?! BDDExecutionError.wrongInputType(type(of: $0), expected: Input.self)) as Input }
                ./ handler
        }
        
        //---
        
        return Given.ModelConnector<Output>(
            scenario: scenario,
            when: when,
            previousClauses: self.previousClauses + [nextGiven]
        )
    }
    
    //===
    
    /**
     Adds subsequent 'GIVEN' clause in Scenario.
     */
    func and<Output>(
        _ specification: String,
        map handler: @escaping (GlobalModel, GivenOutput) throws -> Output
        ) -> Given.ModelConnector<Output>
    {
        typealias Input = GivenOutput
        
        //---
        
        let nextGiven = Given(specification) {
            
            globalModel, previousResult in
            
            //---
            
            return try previousResult
                ./ { $0 as? Input }
                ./ { (try $0 ?! BDDExecutionError.wrongInputType(type(of: $0), expected: Input.self)) as Input }
                ./ { (globalModel, $0) }
                ./ handler
        }
        
        //---
        
        return Given.ModelConnector<Output>(
            scenario: scenario,
            when: when,
            previousClauses: self.previousClauses + [nextGiven]
        )
    }
}

// MARK: - NO output

public
extension Given.ModelConnector
{
    /**
     Adds subsequent 'GIVEN' clause in Scenario that does NOT return anything.
     */
    func and(
        _ specification: String,
        withInput handler: @escaping (GivenOutput) throws -> Void
        ) -> Given.ModelConnector<Void>
    {
        typealias Input = GivenOutput
        
        //---
        
        let nextGiven = Given(specification) {
            
            _, previousResult in
            
            //---
            
            return try previousResult
                ./ { $0 as? Input }
                ./ { (try $0 ?! BDDExecutionError.wrongInputType(type(of: $0), expected: Input.self)) as Input }
                ./ handler
        }
        
        //---
        
        return Given.ModelConnector<Void>(
            scenario: scenario,
            when: when,
            previousClauses: self.previousClauses + [nextGiven]
        )
    }
    
    //===
    
    /**
     Adds subsequent 'GIVEN' clause in Scenario that does NOT return anything.
     */
    func and(
        _ specification: String,
        with handler: @escaping (GlobalModel, GivenOutput) throws -> Void
        ) -> Given.ModelConnector<Void>
    {
        typealias Input = GivenOutput
        
        //---
        
        let nextGiven = Given(specification) {
            
            globalModel, previousResult in
            
            //---
            
            return try previousResult
                ./ { $0 as? Input }
                ./ { (try $0 ?! BDDExecutionError.wrongInputType(type(of: $0), expected: Input.self)) as Input }
                ./ { (globalModel, $0) }
                ./ handler
        }
        
        //---
        
        return Given.ModelConnector<Void>(
            scenario: scenario,
            when: when,
            previousClauses: self.previousClauses + [nextGiven]
        )
    }
}

// MARK: - Returns Bool

public
extension Given.ModelConnector
{
    /**
     Adds subsequent 'GIVEN' clause in Scenario that does NOT return anything.
     */
    func and(
        _ specification: String,
        ifMapInput handler: @escaping (GivenOutput) throws -> Bool
        ) -> Given.ModelConnector<Void>
    {
        typealias Input = GivenOutput

        //---

        let nextGiven = Given(specification) {
            
            _, previousResult in
            
            //---
            
            return try previousResult
                ./ { $0 as? Input }
                ./ { (try $0 ?! BDDExecutionError.wrongInputType(type(of: $0), expected: Input.self)) as Input }
                ./ handler
                ./ Pipeline.throwIfFalse(BDDExecutionError.handlerIndicatedFailure)
        }

        //---

        return Given.ModelConnector<Void>(
            scenario: scenario,
            when: when,
            previousClauses: self.previousClauses + [nextGiven]
        )
    }

    //===

    /**
     Adds subsequent 'GIVEN' clause in Scenario that does NOT return anything.
     */
    func and(
        _ specification: String,
        ifMap handler: @escaping (GlobalModel, GivenOutput) throws -> Bool
        ) -> Given.ModelConnector<Void>
    {
        typealias Input = GivenOutput

        //---

        let nextGiven = Given(specification) {
            
            globalModel, previousResult in
            
            //---
            
            return try previousResult
                ./ { $0 as? Input }
                ./ { (try $0 ?! BDDExecutionError.wrongInputType(type(of: $0), expected: Input.self)) as Input }
                ./ { (globalModel, $0) }
                ./ handler
                ./ Pipeline.throwIfFalse(BDDExecutionError.handlerIndicatedFailure)
        }

        //---

        return Given.ModelConnector<Void>(
            scenario: scenario,
            when: when,
            previousClauses: self.previousClauses + [nextGiven]
        )
    }
}
