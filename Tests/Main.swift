//
//  Main.swift
//  MKHUniFlowTst
//
//  Created by Maxim Khatskevich on 1/12/17.
//  Copyright © 2017 Maxim Khatskevich. All rights reserved.
//

import XCTest

import XCEUniFlow

//===

class Main: XCTestCase
{
    let disp = Dispatcher(defaultReporting: true)
    
    //===
    
    func testArithmetics()
    {
        let ex = expectation(description: "After All Actions")
        
        //===
        
        let proxy = disp.proxy
        
        //===
        
        proxy
            .subscribe(self)
            .onUpdate {
                
                if
                    let a = $0 ==> M.Arithmetics.Main.self
                {
                    print("The value -->> \(a.val)")
                    
                    //===
                    
                    if
                        a.val == 15
                    {
                        ex.fulfill()
                    }
                }
            }
        
        //===
        
        proxy.submit { M.Arithmetics.begin() } // option 1
        // proxy.submit(M.Arithmetics.begin)   // option 2
        
        //===
        
        waitForExpectations(timeout: 1.0)
    }
    
    //===
    
    func testSearch()
    {
        let progressEx = expectation(description: "Progress reached the value 70")
        let ex = expectation(description: "After All Actions")
        
        //===
        
        let proxy = disp.proxy
        
        //===
        
        proxy
            .subscribe(self)
            .onUpdate {
                
                if
                    let s = $0 ==> M.Search.self
                {
                    print("The search -->> \(s)")
                    
                    //===
                    
                    if
                        let p = s as? M.Search.InProgress,
                        p.progress == 70
                    {
                        progressEx.fulfill()
                    }
                    
                    //===
                    
                    if
                        s is M.Search.Failed
                    {
                        ex.fulfill()
                    }
                }
        }
        
        //===
        
        proxy.submit { M.Search.initialize() }
        proxy.submit { M.Search.simulate() }
        
        //===
        
        waitForExpectations(timeout: 1.0)
    }
}
