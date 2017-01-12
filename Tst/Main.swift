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

class Main: XCTestCase
{
    struct GM: AppModel
    {
        var v: Int = 5
    }
    
    //===
    
    let disp = Dispatcher(GM())
    
    //===
    
    func testExample()
    {
        let ex = expectation(description: "After Action")
        
        //===
        
        disp.subscribe(self)
            .onUpdate {
                
                print("The value -->> \($0.v)")
                
                if $0.v == 15
                {
                    ex.fulfill()
                }
            }
        
        disp.submit(act1, with: 10)
        disp.submit(act1, with: 15)
        
        //===
        
        waitForExpectations(timeout: 3.0)
    }
    
    func act1(_ params: ActionParams<Int, GM>) -> Mutation<GM>
    {
        return { $0.v = params.input }
    }
}
