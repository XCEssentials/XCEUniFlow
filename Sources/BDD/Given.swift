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

public
struct Given
{
    // MARK: - Intenral types
    
    typealias PreviousResult = Any
    
    typealias TypelessHandler = (GlobalModel, PreviousResult) -> Any?
    
    // MARK: - Public types
    
    public
    typealias Handler<Input, Output> = (GlobalModel, Input) -> Output?
    
    public
    typealias FirstHandler<Output> = (GlobalModel) -> Output?
    
    // MARK: - Internal members
    
    // declaration / definition
    
    let specification: String
    let implementation: TypelessHandler
    
    // MARK: - Initializers (internal)
    
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

// MARK: - Connector

public
extension Given
{
    struct Connector<Result>
    {
        let previousEntries: [Given]
        
        //===
        
        init(with previousEntries: [Given])
        {
            self.previousEntries = previousEntries
        }
        
        //===
        
        /**
         Adds subsequent 'GIVEN' clauses in Scenario.
         */
        func and<Output>(
            _ specification: String,
            _ subsequentHandler: @escaping Handler<Result, Output>
            ) -> Connector<Output>
        {
            var items = self.previousEntries
            items.append(Given(specification, subsequentHandler))
            
            //---
            
            return Connector<Output>(with: items)
        }
    }
}
