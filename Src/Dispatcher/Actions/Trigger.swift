//
//  Trigger.swift
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
        _ trigger: @escaping (_: ActionParams<Input, State>) throws -> Void,
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
                
                self.process(trigger, with: input)
        }
    }
}

//=== MARK: Internal

extension Dispatcher
{
    func process<Input>(
        _ trigger: @escaping (_: ActionParams<Input, State>) throws -> Void,
        with input: Input
        )
    {
        do
        {
            try trigger((input, state, self))
            
            //===
            
            // no need to notify subscribers,
            // because the state wasn't changed
        }
        catch
        {
            // action has thrown,
            // will NOT notify subscribers
            // about attempt to process this action
            
            onReject.map { $0(.trigger, error) }
        }
    }
}
