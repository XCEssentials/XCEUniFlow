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
        _ trig: @escaping (_: Input, _: State) throws -> Triggers<State>,
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
                
                self.process(trig, with: input)
        }
    }
}

//=== MARK: Internal

extension Dispatcher
{
    func process<Input>(
        _ trig: @escaping (_: Input, _: State) throws -> Triggers<State>,
        with input: Input
        )
    {
        do
        {
            let result = try trig(input, state)
            
            result(self)
            
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
