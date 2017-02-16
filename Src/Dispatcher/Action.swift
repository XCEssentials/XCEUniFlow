//
//  Action.swift
//  MKHUniFlow
//
//  Created by Maxim Khatskevich on 1/12/17.
//  Copyright © 2017 Maxim Khatskevich. All rights reserved.
//

import Foundation

//===

public
struct Action<UFLModel>
{
    let id: String
    
    let body: (UFLModel, (() -> Action<UFLModel>) -> Void, ((inout UFLModel) -> Void) -> Void) throws -> Void
}

//===

public
protocol Feature {}

//===

public
extension Feature
{
    static
    func action<UFLModel>(
        _ name: String = #function,
        _ body: @escaping (UFLModel, (() -> Action<UFLModel>) -> Void, ((inout UFLModel) -> Void) -> Void) throws -> Void
        ) -> Action<UFLModel>
    {
        return Action(id: "\(self).\(name)", body: body)
    }
}

//=== MARK: Public

public
extension Dispatcher
{
    func submit(
        _ actionGetter: () -> Action<State>
        )
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
    func process(
        _ act: Action<State>
        )
    {
        do
        {
            let submit: (_ f: () -> Action<State>) -> Void = {
                
                self.submit($0)
            }
            
            //===
            
            var modelWasMutated = false
            
            let mutate: (_ f: (inout State) -> Void) -> Void = {
                
                $0(&self.state)
                modelWasMutated = true
            }
            
            //===
            
            try act.body(state, submit, mutate)
            
            //===
            
            if
                modelWasMutated
            {
                notifySubscriptions()
            }
        }
        catch
        {
            // action has thrown,
            // will NOT notify subscribers
            // about attempt to process this action
            
            onReject.map { $0(act.id, error) }
        }
    }
}
