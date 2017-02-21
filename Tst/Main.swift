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
    
    func testArithmetics()
    {
        let ex = expectation(description: "After All Actions")
        
        //===
        
        disp.enableDefaultReporting()
        
        disp.subscribe(self)
            .onUpdate {
                
                if
                    let a = $0 ==> M.Arithmetics.Main.self
                {
                    print("The value -->> \(a.v)")
                    
                    //===
                    
                    if
                        a.v == 15
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
    
    //===
    
    func testSearch()
    {
        let ex = expectation(description: "After All Actions")
        
        //===
        
        disp.enableDefaultReporting()
        
        disp.subscribe(self)
            .onUpdate {
                
                if
                    let s = $0 ==> M.Search.self
                {
                    print("The search -->> \(s)")
                    
                    //===
                    
                    if
                        s is M.Search.Failed
                    {
                        ex.fulfill()
                    }
                }
        }
        
        //===
        
        disp.submit { M.Search.initialize() }
        disp.submit { M.Search.simulate() }
        
        //===
        
        waitForExpectations(timeout: 1.0)
    }
}
