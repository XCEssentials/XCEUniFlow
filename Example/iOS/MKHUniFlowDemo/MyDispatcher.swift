//
//  MyDispatcher.swift
//  MKHUniFlowDemo
//
//  Created by Maxim Khatskevich on 2/11/16.
//  Copyright © 2016 Maxim Khatskevich. All rights reserved.
//

import Foundation

import MKHUniFlow

//===

class MyDispatcher: NSObject, UFLDispatcher
{
    typealias MyHandler = (action: MyAction, currentState: MyAppModel) -> (MyAppModel)
    
    private var handlers: [MyHandler] = []
    
    //=== UFLDispatcher protocol
    
    var ufl_handlers: [MyHandler] { return handlers }
    
    func ufl_register(handler: MyHandler)
    {
        handlers.append(handler)
    }
}
