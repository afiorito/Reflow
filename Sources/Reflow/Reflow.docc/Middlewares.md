# Middlewares

Create middleware that intercept, transform and dispatch new actions.

## Overview

Middleware transform actions and can create more actions, while having access to the current state at any point. These actions are passed from middleware to middleware until they reach the reducer.

Middleware are functions that can be registered on store creation:

```swift
let logger: Middleware<CounterState> = { dispatch, getState in
  return { next in
    return { action in
      print("Received action: \(action), with current state: \(getState())")
      next(action)  // pass the action to the next middleware
    }
  }
}

// register the middleware
let store = Store(reducer: CounterState.reducer, initialState: CounterState(count: 0, name: ""), middleware: [logger])
```
