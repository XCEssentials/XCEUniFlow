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

class Observer: PassiveObserver
{
    let onUpdate: (Mutation, GlobalModel) -> Void
    
    //===
    
    init(with onUpdate: @escaping (Mutation, GlobalModel) -> Void)
    {
        self.onUpdate = onUpdate
    }
    
    //===
    
    func update(with mutation: Mutation, model: GlobalModel)
    {
        onUpdate(mutation, model)
    }
}

//===

class Main: XCTestCase
{
    let disp = Dispatcher(defaultReporting: .short)
    
    lazy
    var proxy: Dispatcher.Proxy! = self.disp.proxy
    
    var observer: Observer!
    
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
        observer = nil
        proxy = nil
        
        //===
        
        super.tearDown()
    }
     
    //===
    
    func testArithmetics()
    {
        let ex = expectation(description: "After All Actions")
        
        //===
        
        observer = Observer { _, globalModel in
            
            if
                let a = M.Arithmetics.Main.self << globalModel
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
        
        disp.proxy.subscribe(observer)
        
        //===
        
        proxy << Actions.begin
        
        // proxy << Actions.begin() // option 2
        // proxy.submit { Actions.begin() } // option 3
        // proxy.submit(Actions.begin)   // option 4
        
        //===
        
        waitForExpectations(timeout: 1.0)
    }
    
    //===
    
    func testSearch()
    {
        let progressEx = expectation(description: "Progress reached the value 70")
        let ex = expectation(description: "After All Actions")
        
        //===
        
        observer = Observer { _, globalModel in
            
            guard
                M.Search.presented(in: globalModel)
                else
            {
                return
            }
            
            //===
            
            if
                let p = M.Search.InProgress.from(globalModel),
                p.progress == 70
            {
                progressEx.fulfill()
            }
            
            //===
            
            if
                M.Search.Failed.presented(in: globalModel)
            {
                ex.fulfill()
            }
        }
        
        disp.proxy.subscribe(observer)
        
        //===
        
        proxy << M.Search.initialize
        proxy << M.Search.begin
        
        //===
        
        waitForExpectations(timeout: 1.0)
    }
}
