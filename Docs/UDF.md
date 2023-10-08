# Unidirectional Data Flow

In [information technology](https://en.wikipedia.org/wiki/Information_technology) and [computer science](https://en.wikipedia.org/wiki/Computer_science), a software architecture pattern of applying one-way mutations in synchronous sequential fashion on an otherwise immutable application [state](https://en.wikipedia.org/wiki/State_(computer_science)) is called **unidirectional data flow** (or **UDF** for short reference). Separation of state changes from presentation logic has many benefits for software development, mainly by making it simlper to share application state between different scopes, maintaining data consistency across whole app (since there is single shared data source, i.e. "single source of truth") and enabling granular notifications about all mutations of the application state for all concerned observers across entire app. It was popularized with [Redux](https://en.wikipedia.org/wiki/Redux_(JavaScript_library))  (which itself is based on [Flux](https://github.com/facebookarchive/flux/tree/main/examples/flux-concepts)) for unidirectional data flow combined with [React](https://en.wikipedia.org/wiki/React_(JavaScript_library)) for presenting, or rendering, data state.

A system using the UDF pattern consists of a *store* for holding the current state snapshot, *actions* for requesting state mutations, a *dispatcher* for processing actions and encapsualting store, and a *view* for displaying the state and initiating actions.

1. **Store**: It's a centralized container that holds the most up-to-date snapshot of the application state. It's the single source of truth for the state, ensuring consistency across the application.
1. **Actions**: These are declarative requests that represent the intention to mutate the application's state. Actions define what needs to be done but not how it's done, allowing for a clear separation of concerns.
1. **Dispatcher**: This component encapsulates the store and is responsible for processing actions in a synchronous and sequential fashion. It coordinates the flow of data, ensuring that actions are handled in the correct order and that the state is updated appropriately.
1. **View**: The view consumes the application state from the store and renders the user interface accordingly. It also initiates actions based on user interactions, creating a closed loop within the system. The view ensures that the UI is always a direct representation of the current application state, providing a consistent user experience.

![UDF_flux-simple-f8-diagram-with-client-action-1300w](./UDF_flux-simple-f8-diagram-with-client-action-1300w.png)

Together, these components create a robust and maintainable structure for managing state in an application, with clear pathways for data flow and well-defined responsibilities for each part of the system.

---

## Sources

[^1]: https://en.wikipedia.org/wiki/Unidirectional_Data_Flow_(computer_science)
[^2]: https://github.com/facebookarchive/flux
[^4]:  https://academy.realm.io/posts/benji-encz-unidirectional-data-flow-swift/
[^5]: https://flaviocopes.com/react-unidirectional-data-flow/
[^6]: https://levelup.gitconnected.com/unidirectional-data-flow-in-ios-apps-4e944fc6998c

