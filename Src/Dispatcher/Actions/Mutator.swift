//
//  Mutator.swift
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
    func submit<Input>(
        _ mut: @escaping (_: Input, _: State) throws -> Mutations<State>,
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
                
                self.process(mut, with: input)
        }
    }
}

//=== MARK: Internal

extension Dispatcher
{
    func process<Input>(
        _ mut: @escaping (_: Input, _: State) throws -> Mutations<State>,
        with input: Input
        )
    {
        do
        {
            let result = try mut(input, state)
            
            result(&state)
            
            //===
            
            notifySubscriptions()
        }
        catch
        {
            // action has thrown,
            // will NOT notify subscribers
            // about attempt to process this action
            
            onReject.map { $0(.mutator, error) }
        }
    }
}
