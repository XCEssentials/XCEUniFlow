//
//  Action.swift
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
    func submit<Input>(
        _ action: @escaping (_: ActionParams<Input, State>) throws -> Mutation<State>,
        with input: Input
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
                
                self.process(action, with: input)
        }
    }
}

//=== MARK: Internal

extension Dispatcher
{
    func process<Input>(
        _ action: @escaping (_: ActionParams<Input, State>) throws -> Mutation<State>,
        with input: Input
        )
    {
        do
        {
            let mutation = try action((input, state, self))
            
            mutation(&state)
            
            //===
            
            notifySubscriptions()
        }
        catch
        {
            // action has thrown,
            // will NOT notify subscribers
            // about attempt to process this action
            
            onReject.map { $0(.action, error) }
        }
    }
}
