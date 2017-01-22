//
//  ActionShort.swift
//  MKHUniFlow
//
//  Created by Maxim Khatskevich on 1/12/17.
//  Copyright © 2017 Maxim Khatskevich. All rights reserved.
//

import Foundation

//=== MARK: Public

public
extension Dispatcher
{
    func submit(
        _ actS: @escaping (_: State, _: Dispatcher<State>) throws -> Mutations<State>
        )
    {
        OperationQueue
            .main
            .addOperation {
                
                // we add this action to queue async-ly,
                // to make sure it will be processed AFTER
                // current execution is completes,
                // that even allows from an Action handler
                // to submit another Action
                
                self.process(actS)
            }
    }
}

//=== MARK: Internal

extension Dispatcher
{
    func process(
        _ actS: @escaping (_: State, _: Dispatcher<State>) throws -> Mutations<State>
        )
    {
        do
        {
            let mutation = try actS(state, self)
            
            mutation(&state)
            
            //===
            
            notifySubscriptions()
        }
        catch
        {
            // action has thrown,
            // will NOT notify subscribers
            // about attempt to process this action
            
            onReject.map { $0(.actionShort, error) }
        }
    }
}
