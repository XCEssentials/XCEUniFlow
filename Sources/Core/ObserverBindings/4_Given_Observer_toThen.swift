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

//===

public
extension Given.ObserverConnector where GivenOutput == Void
{
    func then(
        _ specification: String,
        do handler: @escaping (Observer) -> Void
        ) -> ObserverBinding
    {
        return ObserverBinding(
            context: scenario.context,
            summary: scenario.summary,
            when: when,
            given: previousClauses,
            then: ObserverBinding.Then(specification) {
                
                observer, _ in
                
                //---
                
                try observer
                    ./ { $0 as? Observer }
                    ./ { (try $0 ?! BDDExecutionError.wrongObserverType(type(of: $0), expected: Observer.self)) as Observer }
                    ./ handler
            }
        )
    }
}

//===

public
extension Given.ObserverConnector
{
    func then(
        _ specification: String,
        do handler: @escaping (Observer, GivenOutput) -> Void
        ) -> ObserverBinding
    {
        typealias Input = GivenOutput
        
        //---
        
        return ObserverBinding(
            context: scenario.context,
            summary: scenario.summary,
            when: when,
            given: previousClauses,
            then: ObserverBinding.Then(specification) {
                
                observer, previousResult in
                
                //---
                
                try (
                    observer
                        ./ { $0 as? Observer }
                        ./ { try $0 ?! BDDExecutionError.wrongObserverType(type(of: $0), expected: Observer.self) },
                    previousResult
                        ./ { $0 as? Input }
                        ./ { try $0 ?! BDDExecutionError.wrongInputType(type(of: $0), expected: Input.self) }
                    )
                    ./ handler
            }
        )
    }
}
