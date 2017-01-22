//
//  TriggerShort.swift
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
        _ trigS: @escaping (_: State, _: Dispatcher<State>) throws -> Void
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
                
                self.process(trigS)
            }
    }
}

//=== MARK: Internal

extension Dispatcher
{
    func process(
        _ trigS: @escaping (_: State, _: Dispatcher<State>) throws -> Void
        )
    {
        do
        {
            try trigS(state, self)
            
            //===
            
            // no need to notify subscribers,
            // because the state wasn't changed
        }
        catch
        {
            // action has thrown,
            // will NOT notify subscribers
            // about attempt to process this action
            
            onReject.map { $0(.triggerShort, error) }
        }
    }
}
