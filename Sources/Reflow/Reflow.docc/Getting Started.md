# Getting Started

Create a basic store and dispatch actions and effects to manipulate the state.

## Overview

The store is a container that manages state manipulations through dispatched actions. While actions cause simple state manipulations after passing through reducers, effects allow more complicated state interactions. As their name suggests, they can make network calls, interact with the file manager or other side effects. 

### Basic Usage

1\. Create a state representation.

```swift
struct CounterState {
  var count: Int
  var name: String
}
```

2\. Create a dispatchable action.

```swift
enum CounterAction: Action {
  case increment
  case loadedName(String)
}
```

3\. Create a reducer.

```swift
struct CounterState: Equatable {
  ...

  static func reducer(state: Self, action: Action) -> Self {
    switch action {
      case CounterAction.increment:
        return Self(count: state.count + 1, name: state.name)
      case CounterAction.loadedName(let name):
        return Self(count: state.count, name: name)
      default:
          return state
    }
  }
}
```

4\. Create a store.

```swift
let store = Store(reducer: CounterState.reducer, initialState: CounterState(count: 0, name: ""))
```

5\. Dispatch an action.

```swift
store.dispatch(CounterAction.increment)
```

6\. Subscribe to the store.

```swift
let cancellable = store
  .select { state in state.count }
  .sink { count in
    // prints "Received count: 0" before any actions are dispatched
    // prints "Received count: 1" after action is dispatched
    print("Received count: \(count)")
  }
```

### Combine Reducers

As your application state becomes more complex and you create more actions, it may be useful to split your state into multiple reducers. Each reducer handles a single key of your state.

```swift
struct AuthState {
  var token: String

  static func reducer(state: Self, action: Action) -> Self {
    return state
  }
}

struct AppState {
  var counter = CounterState(count: 0, name: "")
  var auth = AuthState(token: "")
}

let reducers: Reducer<AppState> = combineReducers(
  withKey(\.counter, use: CounterState.reducer),
  withKey(\.auth, use: AuthState.reducer)
)

// pass the combined reducers to the store
let store = Store(reducer: reducers, initialState: AppState())
```

## Topics

### Advanced Topics

- <doc:Effects>
- <doc:Middlewares>
