//
//  Main.swift
//  MKHUniFlowTst
//
//  Created by Maxim Khatskevich on 1/12/17.
//  Copyright © 2017 Maxim Khatskevich. All rights reserved.
//

import XCTest

import MKHUniFlow

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
