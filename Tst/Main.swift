//
//  Main.swift
//  MKHUniFlowTst
//
//  Created by Maxim Khatskevich on 1/12/17.
//  Copyright © 2017 Maxim Khatskevich. All rights reserved.
//

import XCTest

//@testable
import MKHUniFlow

//===

struct GM: AppModel
{
    var v: Int? = nil
}

//===

enum ArithmeticMutations
{
    static
    func setExplicit(p: ActionParams<Int, GM>) -> Mutation<GM>
    {
        return { $0.v = p.input }
    }
    
    static
    func incFive(p: ActionShortParams<GM>) throws -> Mutation<GM>
    {
        // this check is unnecessary here, just for demonstration:
        try UFL.verify("Current value was set", self){ p.state.v != nil }
        
        //===
        
        // this check ensures that current value is not nil,
        // as well as unwraps it for further use:
        let v = try UFL.extract("Get current value", self){ p.state.v }
        
        //===
        
        return { $0.v = v + 5 }
    }
}

//===

class Main: XCTestCase
{
    let disp = Dispatcher(GM())
    
    //===
    
    func testExample()
    {
        let ex = expectation(description: "After All Actions")
        
        //===
        
        disp.enableDefaultReporting()
        
        disp.subscribe(self)
            .onUpdate {
                
                print("The value -->> \($0.v)")
                
                //===
                
                if $0.v == 15
                {
                    ex.fulfill()
                }
            }
        
        //===
        
        disp.submit(
            ArithmeticMutations.setExplicit, with: 10)
        
        disp.submit(
            ArithmeticMutations.incFive)
        
        //===
        
        waitForExpectations(timeout: 1.0)
    }
    
    
}
