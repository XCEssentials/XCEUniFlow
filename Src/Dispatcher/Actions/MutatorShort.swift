//
//  MutatorShort.swift
//  MKHUniFlow
//
//  Created by Maxim Khatskevich on 1/16/17.
//  Copyright © 2017 Maxim Khatskevich. All rights reserved.
//

import Foundation

//=== MARK: Public

public
extension Dispatcher
{
    func submit(
        _ mutS: @escaping (_: State) throws -> Mutations<State>
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
                
                self.process(mutS)
        }
    }
}

//=== MARK: Internal

extension Dispatcher
{
    func process(
        _ mutS: @escaping (_: State) throws -> Mutations<State>
        )
    {
        do
        {
            let result = try mutS(state)
            
            result(&state)
            
            //===
            
            notifySubscriptions()
        }
        catch
        {
            // action has thrown,
            // will NOT notify subscribers
            // about attempt to process this action
            
            onReject.map { $0(.mutatorShort, error) }
        }
    }
}
