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
        let v: Int = 5
    }
    
    func testExample()
    {
        let state = GM()
        
        let _ = Dispatcher(state)
        
        //
    }
}
