//
//  First.swift
//  MKHUniFlow
//
//  Created by Maxim Khatskevich on 1/12/17.
//  Copyright © 2017 Maxim Khatskevich. All rights reserved.
//

import Foundation

//===

public
protocol DispatcherBindable: class
{
    associatedtype State
    
    func bind(with dispatcher: Dispatcher) -> Self
}

//===

public
protocol DispatcherInitializable: class
{
    associatedtype State
    
    init(with dispatcher: Dispatcher)
}
