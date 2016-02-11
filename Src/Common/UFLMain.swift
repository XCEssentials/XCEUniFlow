//
//  UFLMain.swift
//  MKHUniFlow
//
//  Created by Maxim Khatskevich on 2/10/16.
//  Copyright © 2016 Maxim Khatskevich. All rights reserved.
//

//===

// STATE == MODEL

// Observer

// Dispatcher

//===

// Observer.configure(subState)

// Dispatcher.subscribe(observer)
// Observer.subscribe(dispatcher)

// Observer.reduce(GlobalState) -> SubState

// Dispatcher.reduce(GlobalState, forObserver: Observer) -> SubState

//===

// Observer.configure(globalState: SubStateProtocol)

//===



// generateRepresentation(state) -> Model


// -> Action(params) -> Dispatcher -> Action(params)+State -> reducer1 -> Action(params)+State -> ... -> reducerN -> Dixpatcher -> newState -> Observers


// Do we split LOGIC and UI state/actions/events?

// Logic action/event may derive/trigger corresponding UI update

// Separate dispatcher for logic and UI actions?

//===

public protocol UFLState { }

//===

public protocol UFLAction { }

//===

public protocol UFLDispatcher
{
    typealias StateType: UFLState
    typealias ActionType: UFLAction
    
    // to make sure there is no side effects
    // handler is just a block of code with no ability
    // to save any state inside
    
    // this property should return all registered handlers
    var ufl_handlers: [(action: ActionType, currentState: StateType) -> (StateType)] { get }
    
    // it's up to developer to decide if this handler should be accepted or not
    func ufl_register(handler: (action: ActionType, currentState: StateType) -> (StateType))
}

public extension UFLDispatcher
{
    //
}

//===

// Action == Request (to dispatcher/store/etc.) ?
// Handler == Responder, Processor, response contains only new state/model ?

// Same action might be processed by one or multiple handlers/responders,
// good example is when one responder do the real job and another one is
// just sending a signal to analytics server

public protocol UFLHandler
{
    typealias StateType: UFLState
    typealias ActionType: UFLAction
    
    // explicitly declare that actions can be processed by this handler
    var ufl_compatibleWith: [ActionType] { get }
    
    // static func to make sure there is NO side effects involved
    static func ufl_handle(action: ActionType, currentState: StateType) -> (StateType)
}









//===


