//
//  ActionProcessing.swift
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
    func submit(_ actionGetter: @autoclosure () -> Action)
    {
        let act = actionGetter()
        
        //===
        
        OperationQueue
            .main
            .addOperation {
                
                // we add this action to queue async-ly,
                // to make sure it will be processed AFTER
                // current execution is completes,
                // that even allows from an Action handler
                // to submit another Action
                
                self.process(act)
            }
    }
    
    func submit(_ actionGetter: () -> Action)
    {
        let act = actionGetter()
        
        //===
        
        OperationQueue
            .main
            .addOperation {
                
                // we add this action to queue async-ly,
                // to make sure it will be processed AFTER
                // current execution is completes,
                // that even allows from an Action handler
                // to submit another Action
                
                self.process(act)
            }
    }
}

//=== MARK: Internal

extension Dispatcher
{
    func process(_ act: Action)
    {
        do
        {
            try act.body(model, { $0(&self.model) }, { self.submit($0) })
            
            //===
            
            notifySubscriptions()
        }
        catch
        {
            // action has thrown,
            // will NOT notify subscribers
            // about attempt to process this action
            
            onReject.map { $0(act.name, error) }
        }
    }
}
