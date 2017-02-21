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
    let disp = Dispatcher()
    
    //===
    
    func testRegularActions()
    {
        let ex = expectation(description: "After All Actions")
        
        //===
        
        disp.enableDefaultReporting()
        
        disp.subscribe(self)
            .onUpdate {
                
                if
                    let v = M.Arithmetics.extracted(from: $0)?.v
                {
                    print("The value -->> \(v)")
                    
                    //===
                    
                    if v == 15
                    {
                        ex.fulfill()
                    }
                }
            }
        
        //===
        
        disp.submit { M.Arithmetics.begin() } // option 1
        // disp.submit(M.Arithmetics.begin()) // option 2
        // disp.submit(M.Arithmetics.begin)   // option 3
        
        //===
        
        waitForExpectations(timeout: 1.0)
    }
    
    func testFeature()
    {
        //
    }
}
