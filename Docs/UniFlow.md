# UniFlow

**UniFlow** (or **UFL** for short reference) is an opinionated *software architecture pattern* that combines together concepts and principles from **finite state machine** ([FSM](https://en.wikipedia.org/wiki/Finite-state_machine)) & **unidirectional data flow** ([UDF](https://en.wikipedia.org/wiki/Unidirectional_Data_Flow_(computer_science))). In other words, the FSM's framework for defining states and transitions is combined with UDF's methodology for managing data flow and state mutations, with few notable extensions that leave less room for guessing and provide more clarity on intended implementaiton of this pattern.

Business logic, rules entities !!!

Here is how UFL system works. Entire application functionality is broken down into a set of *features*. Each feature is represented as a finite state machine ([FSM](https://en.wikipedia.org/wiki/Finite-state_machine)). That means each feature consists of a finite number of *states* (FSM) that represent application data model, as well as *actions* (UDF) that represent business logic. Each action consist of transitions ([FSM](https://en.wikipedia.org/wiki/Finite-state_machine)) between states, and any associated operations ([FSM](https://en.wikipedia.org/wiki/Finite-state_machine)).



![UFL-UML-Seq](/Users/maxim/Library/Mobile Documents/com~apple~CloudDocs/Dev/XCEssentials/UniFlow-LLM/UFL-UML-Seq.png)



A system using the UFL must implement following key rules:

1. Application state consists of a finite number of *states*;
2. 





consists of a finite number of *states*, transitons between those states and any necessary associated operations, alternative states that logically belong together are grouped into *features*,  *transitions* between those states, and *operations* that can be executed when those transitions occur. Here's a breakdown of the main components:



Extensions for Finite State Machine Components (FSM):

- 

Extensions for Unidirectional Data Flow Components (UDF):

- **Store**: **It's a centralized container that holds the most up-to-date snapshot of the application state. It's the single source of truth for the state, ensuring consistency across the application.**
- **Actions**: Note that each action can be either *processed* successfully, or *rejected* by the dispatcher, depending on the current application state and *requirements* (a.k.a. *preconditions*) specified in particular action, or if any of the operations included in the action fail.

This enables a robust and flexible system for managing both control flow and application state, creating a cohesive design pattern for software architecture.



- 



Remember:

* describe water feature is...
* each feature should be always considered within context of particular **dispatcher**;
* 
* from dispatcher point of you, any given feature is either **initialised** or **not initialised** at any given point in time;
* 
* Dispatcher is a special object that manages all the transitions between states of different features and keeps track of all features and the respective state
* 
