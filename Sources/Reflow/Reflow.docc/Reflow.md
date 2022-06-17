# ``Reflow``

Reflow is a Redux-like implementation of the unidirectional data flow architecture in Swift using Combine.

## Overview

Reflow relies on a few concepts:

- A ``Store`` contains the entire state of your app in a single data structure. The state is modified by dispatching actions to the store. Whenever the state changes, all selectors are updated via a Combine publisher.

- A ``Reducer`` is a pure function that when given action, uses the current state to create a new state.

- An ``Action`` is a way of describing a change in state. Actions don't have logic, they are dispatched to the store and processed by reducers.

![Flow](flow.png)

It's important to know that the ``Store`` class is not thread-safe, all changes to the store's state must be done on the same thread.

## Topics

### Essentials

- <doc:Getting-Started>

### Store creation

- ``Store``
- ``combineReducers(_:)``
- ``withKey(_:use:)``
- ``Reducer``

### Actions and effects
- ``Action``
- ``Effect``
- ``AsyncEffect``
- ``Dispatch``

### Middleware

- ``Middleware``
