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
    
    var proxy: Dispatcher.Proxy!
    
    //===
    
    override
    func setUp()
    {
        super.setUp()
        
        //===
        
        //
    }
    
    override
    func tearDown()
    {
        proxy = nil
        
        //===
        
        super.tearDown()
    }
     
    //===
    
    func testArithmetics()
    {
        let ex = expectation(description: "After All Actions")
        
        //===
        
        proxy = disp.proxy.subscribe { globalModel, _ in
            
            if
                let a = globalModel ==> M.Arithmetics.Main.self
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
        
        proxy = disp.proxy.subscribe { globalModel, change in
                
            if
                let s = globalModel ==> M.Search.self
            {
                print("The search -->> \(s)")
                print("CHANGE: -->> \(String(reflecting: change))")
                print("CHANGE: -->> \(change)")
                
                //===
                
                if
                    // change: MutationAnnotation.Type
                    change is FeatureMutation.Type,
                    change == Initialization<M.Search>.self,
                    change is Initialization<M.Search>.Type,
                    let change = change as? FeatureMutation.Type,
                    change.feature == M.Search.self
                {
                    print("YES")
                }
                else
                {
                    print("NO")
                }
                
                if
                    let p = s as? M.Search.InProgress,
                    p.progress == 70
//                    myChanges.kind == .actualization
//                    M.Search.transition.Between<M.Search.Ready, M.Search.InProgress>.self == changes
                    // changes is Updated<M.Search.InProgress>
                    // changes is Removed<M.Search>
                    // changes is Updated<M.Search>
                    // changes is Updated<M.Search>.kind == .removed
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
        proxy.submit { M.Search.begin() }
        
        //===
        
        waitForExpectations(timeout: 1.0)
    }
}
