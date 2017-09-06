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

class Observer: StateObserver
{
    let onUpdate: (GlobalModel, GlobalMutation?) -> Void
    
    //===
    
    init(with onUpdate: @escaping (GlobalModel, GlobalMutation?) -> Void)
    {
        self.onUpdate = onUpdate
    }
    
    //===
    
    func update(with globalModel: GlobalModel, mutation: GlobalMutation?)
    {
        onUpdate(globalModel, mutation)
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
        
        observer = Observer { globalModel, _ in
            
            if
                let a = Arithmetics.Main.self << globalModel
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
        
        proxy << Arithmetics.begin
        
        //===
        
        waitForExpectations(timeout: 1.0)
    }
    
    //===
    
    func testSearch()
    {
        let progressEx = expectation(description: "Progress reached the value 70")
        let ex = expectation(description: "After All Actions")
        
        //===
        
        observer = Observer { globalModel, _ in
            
            guard
                Search.presented(in: globalModel)
            else
            {
                return
            }
            
            //===
            
            if
                let p = Search.InProgress.from(globalModel),
                p.progress == 70
            {
                progressEx.fulfill()
            }
            
            //===
            
            if
                Search.Failed.presented(in: globalModel)
            {
                ex.fulfill()
            }
        }
        
        disp.proxy.subscribe(observer)
        
        //===
        
        proxy << Search.setup
        proxy << Search.begin
        
        //===
        
        waitForExpectations(timeout: 1.0)
    }
}
