# Finite State Machine

A **Finite State Machine** (also known as **FSM**) is a computational model used to represent and control execution flow. It's often used in computer science and engineering to describe the operational behavior of a system[^1].

An FSM consists of a *finite number of states*, *transitions* between those states, and *operations* that can be executed when those transitions occur. Here's a breakdown of the main components:

1. **States**. A finite set of conditions or situations, each uniquely identified by its *name*. At any given time, the machine is in one of these states, for as long as it exists (present). The current state is called the *active state*.
2. **Transitions**. Rules that define how the machine moves from one state to another. Transitions are triggered by events or conditions, and they may also involve executing certain associated operations.
3. **Initial State**. One of the states is defined as the initial state, where the machine begins its operation. It does not have an explicit name.
4. **Final State(s)**. In some FSMs, there may be one or more final states that indicate the completion of a particular operation or sequence (that this particular FSM repesents). It is completely valid for FSM to have no final states at all (zero), meaning that model is meant to keep running indefinitely.
5. **Operations**: These are associated tasks that can be executed when a particular transition occurs. Operations can also be *associated directly with states*, either upon entering or exiting the state.

## Applications

Finite state machines are widely used in various fields, including:

- **Computer Algorithms**: Parsing text, lexical analysis, pattern matching, etc.
- **Computer Software**: Describing individual pieces of business logic, GUI components and overall software features.
- **Control Systems**: Describing the operational behavior of machines, elevators, traffic lights, etc.
- **Telecommunications**: Protocols and signal processing.
- **Game Development**: Controlling character behavior, game states, etc.

## Example

A simple example of an FSM is a turnstile. It has two states:

1. **Locked**: The turnstile is locked and won't allow entry.
2. **Unlocked**: The turnstile is unlocked and allows entry.

Transitions between these states occur based on coin insertion and push events. If a coin is inserted while the turnstile is locked, it transitions to the unlocked state. If the turnstile is pushed while unlocked, it transitions back to the locked state.

![FSM_Turnstile_state_machine_colored](./FSM_Turnstile_state_machine_colored.svg)

FSMs provide a concise and clear way to model complex systems, making them a valuable tool in various domains.

---

## Sources
[^1]: https://en.wikipedia.org/wiki/Finite-state_machine
[^2]: https://brilliant.org/wiki/finite-state-machines/