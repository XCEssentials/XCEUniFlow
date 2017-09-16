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

//import XCERequirement

//===

/**
 
 Example:
 
 AS the app owner
 IN ORDER TO retain users
 I WANT TO provide smooth and pleasant FTUE.
 
 */
public
typealias StorySummary = (as: String, inOrderTo: String, wantTo: String)

public
protocol Story
{
//    static
//    var name: String { get }
//
//    static
//    var summary: StorySummary { get }
    
    static
    var scenarios: [Scenario] { get }
}

//===

public
extension Story where Self: Feature
{
    static
    var middleware: [Dispatcher.Middleware]
    {
        return scenarios.map { $0.asMiddleware }
    }
}

//===

public
struct Given
{
    typealias PreviousResult = Any
    
    typealias TypelessHandler = (GlobalModel, PreviousResult) -> Any?
    
    public
    typealias Handler<Input, Output> = (GlobalModel, Input) -> Output?
    
    public
    typealias FirstHandler<Output> = (GlobalModel) -> Output?
    
    // declaration / definition
    
    let specification: String
    let implementation: TypelessHandler
    
    //===
    
    fileprivate
    init<Output>(
        _ specification: String,
        _ firstHandler: @escaping FirstHandler<Output>
        )
    {
        self.specification = specification
        
        self.implementation = { globalModel, _ in
            
            return firstHandler(globalModel)
        }
    }
    
    fileprivate
    init<Input, Output>(
        _ specification: String,
        _ subsequentHandler: @escaping Handler<Input, Output>
        )
    {
        self.specification = specification
        
        self.implementation = { globalModel, previousResult in
            
            guard
                let typedPreviousResult = previousResult as? Input
            else
            {
                return nil
            }
            
            //===
            
            return subsequentHandler(globalModel, typedPreviousResult)
        }
    }
}

//===

public
extension Given
{
    struct Connector<Result>
    {
        let items: [Given]
        
        fileprivate
        init(with items: [Given])
        {
            self.items = items
        }
    }
}

//===

public
extension Story
{
    // first "given" clause
    static
    func given<Output>(
        _ specification: String,
        _ firstHandler: @escaping Given.FirstHandler<Output>
        ) -> Given.Connector<Output>
    {
        return Given.Connector<Output>(with: [Given(specification, firstHandler)])
    }
}

//===

public
extension Given.Connector
{
    // for second and next "and" calls, third and next "given" clauses
    func and<Output>(
        _ specification: String,
        _ subsequentHandler: @escaping Given.Handler<Result, Output>
        ) -> Given.Connector<Output>
    {
        var items = self.items
        items.append(Given(specification, subsequentHandler))
        
        //---
        
        return Given.Connector<Output>(with: items)
    }
    
    //===
    
    func when(
        _ specification: String,
        _ standardHanlder: @escaping (GlobalMutation) -> Bool
        ) -> When.Connector<Result>
    {
        return When.Connector(
            with: items,
            when: When(specification, standardHanlder)
        )
    }
    
    //===
    
    func when(
        _ specification: String,
        _ specialHanlder: @escaping (GlobalMutation) -> GlobalMutation?
        ) -> When.Connector<Result>
    {
        return When.Connector(
            with: items,
            when: When(specification, specialHanlder)
        )
    }
}

//===

public
struct When
{
    public
    typealias Handler = (GlobalMutation) -> Bool // continue if -> YES
    
    public
    typealias SpecialHandler = (GlobalMutation) -> GlobalMutation?
    
    //===
    
    let specification: String
    let implementation: Handler
    
    // MARK: - Initializers
    
    fileprivate
    init(
        _ specification: String,
        _ standardHanlder: @escaping Handler
        )
    {
        self.specification = specification
        self.implementation = standardHanlder
    }
    
    fileprivate
    init(
        _ specification: String,
        _ specialHanlder: @escaping SpecialHandler
        )
    {
        self.specification = specification
        self.implementation = { return specialHanlder($0) != nil }
    }
}

//===

public
extension When
{
    public
    struct Connector<GivenResult>
    {
        let given: [Given]
     
        let when: When
        
        fileprivate
        init(with given: [Given], when: When)
        {
            self.given = given
            self.when = when
        }
    }
}

//===

public
extension When.Connector
{
    func then(
        _ specification: String,
        _ handler: @escaping Then.Handler<GivenResult>
        ) -> Scenario
    {
        return Scenario(
            given: given,
            when: when,
            then: Then(specification, handler)
        )
    }
    
    //===
    
    func then(_ specification: String, submit action: Action) -> Scenario
    {
        return Scenario(
            given: given,
            when: when,
            then: Then(specification) { (submit, _: GivenResult) in
                
                submit << action
            }
        )
    }
    
    //===
    
    func then(_ specification: String, submit actions: [Action]) -> Scenario
    {
        return Scenario(
            given: given,
            when: when,
            then: Then(specification) { (submit, _: GivenResult) in
                
                submit << actions
            }
        )
    }
}

//===

public
struct Then
{
    public
    typealias TypelessHandler = (SubmitAction, Any) -> Void

    public
    typealias Handler<Input> = (SubmitAction, Input) -> Void

    let specification: String
    let implementation: TypelessHandler

    fileprivate
    init<Input>(
        _ specification: String,
        _ handler: @escaping Handler<Input>
        )
    {
        self.specification = specification
        
        self.implementation = { submit, previousResult in
            
            guard
                let typedPreviousResult = previousResult as? Input
            else
            {
                return
            }
            
            //===
            
            return handler(submit, typedPreviousResult)
        }
    }
}

//===

public
struct Scenario
{
    let given: [Given]
    let when: When
    let then: Then
}

//===

// internal!!!
extension Scenario
{
    func shouldReact(on mutation: GlobalMutation) -> Bool
    {
        return when.implementation(mutation)
    }
    
    //===
    
    var asMiddleware: Dispatcher.Middleware
    {
        return { globalModel, mutation, submit in
        
            guard
                self.shouldReact(on: mutation)
            else
            {
                return
            }
            
            //--
            
            var givenResult: Given.PreviousResult? = ()
            
            for item in self.given
            {
                guard
                    let input = givenResult
                else
                {
                    break
                }
                
                //---
                
                givenResult = item.implementation(globalModel, input)
            }
            
            //--
            
            guard
                let thenInput = givenResult
            else
            {
                return
            }
            
            //--
            
            self.then.implementation(submit, thenInput)
        }
    }
}

//===

/**
 
 // GIVEN works like flatMap - stops chain if return nil
 
 Given("Description") { globalModel in ... return value? }
 .and("Description") { globalModel in ... return value? }
 ...
 .when("Description", TransitionInto<M.MostRecent.Found>.init)
 .then("Description") { submit in ... } // does NOT return anything
 
 */
