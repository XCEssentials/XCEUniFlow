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

// MARK: - With output

public
extension When.ModelConnector
{
    /**
     Defines first 'GIVEN' clause in a Scenario.
     */
    func given<Output>(
        _ specification: String,
        mapState handler: @escaping (GlobalModel) throws -> Output
        ) -> Given.ModelConnector<Output>
    {
        let firstGiven = Given(first: true, specification) { globalModel, _ in
            
            return try handler(globalModel)
        }
        
        //---
        
        return Given.ModelConnector<Output>(
            scenario: scenario,
            when: when,
            previousClauses: [firstGiven]
        )
    }
    
    //===
    
    /**
     Defines first 'GIVEN' clause in a Scenario.
     */
    func given<Output>(
        _ specification: String,
        mapMutation handler: @escaping (WhenOutput) throws -> Output
        ) -> Given.ModelConnector<Output>
    {
        typealias Input = WhenOutput
        
        //---
        
        let firstGiven = Given(first: true, specification) {
            
            _, previousResult in
            
            //---
            
            return try previousResult
                ./ { $0 as? Input }
                ./ { try $0 ?! BDDExecutionError.wrongInputType(type(of: $0), expected: Input.self) }
                ./ handler
        }
        
        //---
        
        return Given.ModelConnector<Output>(
            scenario: scenario,
            when: when,
            previousClauses: [firstGiven]
        )
    }
    
    //===
    
    /**
     Defines first 'GIVEN' clause in a Scenario.
     */
    func given<Output>(
        _ specification: String,
        map handler: @escaping (GlobalModel, WhenOutput) throws -> Output
        ) -> Given.ModelConnector<Output>
    {
        typealias Input = WhenOutput
        
        //---
        
        let firstGiven = Given(first: true, specification) {
            
            globalModel, previousResult in
            
            //---
            
            return try previousResult
                ./ { $0 as? Input }
                ./ { try $0 ?! BDDExecutionError.wrongInputType(type(of: $0), expected: Input.self) }
                ./ { (globalModel, $0) }
                ./ handler
        }
        
        //---
        
        return Given.ModelConnector<Output>(
            scenario: scenario,
            when: when,
            previousClauses: [firstGiven]
        )
    }
}

// MARK: - NO output

public
extension When.ModelConnector
{
    /**
     Defines first 'GIVEN' clause in a Scenario that does NOT return anything.
     */
    func given(
        _ specification: String,
        withState handler: @escaping (GlobalModel) throws -> Void
        ) -> Given.ModelConnector<Void>
    {
        let firstGiven = Given(first: true, specification) { globalModel, _ in
            
            try handler(globalModel)
            
            //---
            
            return ()
        }
        
        //---
        
        return Given.ModelConnector<Void>(
            scenario: scenario,
            when: when,
            previousClauses: [firstGiven]
        )
    }
    
    //===
    
    /**
     Defines first 'GIVEN' clause in a Scenario that does NOT return anything.
     */
    func given(
        _ specification: String,
        withMutation handler: @escaping (WhenOutput) throws -> Void
        ) -> Given.ModelConnector<Void>
    {
        typealias Input = WhenOutput
        
        //---
        
        let firstGiven = Given(first: true, specification) {
            
            _, previousResult in
            
            //---
            
            try previousResult
                ./ { $0 as? Input }
                ./ { try $0 ?! BDDExecutionError.wrongInputType(type(of: $0), expected: Input.self) }
                ./ handler
            
            //---
            
            return ()
        }
        
        //---
        
        return Given.ModelConnector<Void>(
            scenario: scenario,
            when: when,
            previousClauses: [firstGiven]
        )
    }
    
    //===
    
    /**
     Defines first 'GIVEN' clause in a Scenario that does NOT return anything.
     */
    func given(
        _ specification: String,
        with handler: @escaping (GlobalModel, WhenOutput) throws -> Void
        ) -> Given.ModelConnector<Void>
    {
        typealias Input = WhenOutput
        
        //---
        
        let firstGiven = Given(first: true, specification) {
            
            globalModel, previousResult in
            
            //---
            
            try previousResult
                ./ { $0 as? Input }
                ./ { try $0 ?! BDDExecutionError.wrongInputType(type(of: $0), expected: Input.self) }
                ./ { (globalModel, $0) }
                ./ handler
            
            //---
            
            return ()
        }
        
        //---

        return Given.ModelConnector<Void>(
            scenario: scenario,
            when: when,
            previousClauses: [firstGiven]
        )
    }
}

// MARK: - Returns Bool

public
extension When.ModelConnector
{
    /**
     Defines first 'GIVEN' clause in a Scenario that does NOT return anything.
     */
    func given(
        _ specification: String,
        ifMapState handler: @escaping (GlobalModel) throws -> Bool
        ) -> Given.ModelConnector<Void>
    {
        let firstGiven = Given(first: true, specification) {
            
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
            previousClauses: [firstGiven]
        )
    }

    //===

    /**
     Defines first 'GIVEN' clause in a Scenario that does NOT return anything.
     */
    func given(
        _ specification: String,
        ifMapMutation handler: @escaping (WhenOutput) throws -> Bool
        ) -> Given.ModelConnector<Void>
    {
        typealias Input = WhenOutput

        //---

        let firstGiven = Given(first: true, specification) {
            
            _, previousResult in
            
            //---
            
            return try previousResult
                ./ { $0 as? Input }
                ./ { try $0 ?! BDDExecutionError.wrongInputType(type(of: $0), expected: Input.self) }
                ./ handler
                ./ Pipeline.throwIfFalse(BDDExecutionError.handlerIndicatedFailure)
        }

        //---

        return Given.ModelConnector<Void>(
            scenario: scenario,
            when: when,
            previousClauses: [firstGiven]
        )
    }

    //===

    /**
     Defines first 'GIVEN' clause in a Scenario that does NOT return anything.
     */
    func given(
        _ specification: String,
        ifMap handler: @escaping (GlobalModel, WhenOutput) throws -> Bool
        ) -> Given.ModelConnector<Void>
    {
        typealias Input = WhenOutput

        //---

        let firstGiven = Given(first: true, specification) {
            
            globalModel, previousResult in
            
            //---

            try previousResult
                ./ { $0 as? Input }
                ./ { try $0 ?! BDDExecutionError.wrongInputType(type(of: $0), expected: Input.self) }
                ./ { (globalModel, $0) }
                ./ handler
                ./ Pipeline.throwIfFalse(BDDExecutionError.handlerIndicatedFailure)

            //---

            return ()
        }

        //---

        return Given.ModelConnector<Void>(
            scenario: scenario,
            when: when,
            previousClauses: [firstGiven]
        )
    }
}
