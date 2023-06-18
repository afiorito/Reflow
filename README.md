# ![icon](reflow.png) Reflow

Reflow is a [Redux](https://github.com/reactjs/redux)-like implementation of the unidirectional data flow architecture in Swift using Combine.

## About Reflow

Reflow relies on a few concepts:

- A **Store** contains the entire state of your app in a single data structure. The state is modified by dispatching actions to the store. Whenever the state changes, all selectors are updated via a Combine publisher.

- A **Reducer** is a pure function that when given action, uses the current state to create a new state.

- An **Action** is a way of describing a change in state. Actions don't have logic, they are dispatched to the store and processed by reducers.

<picture>
  <source media="(prefers-color-scheme: dark)" srcset="./Sources/Reflow/Reflow.docc/Resources/flow~dark@2x.png">
  <source media="(prefers-color-scheme: light)" srcset="./Sources/Reflow/Reflow.docc/Resources/flow@2x.png">
  <img alt="Reflow Lifecycle" src="./Sources/Reflow/Reflow.docc/Resources/flow">
</picture>

## Installation

Add Reflow to your project using Swift Package Manager. In your Xcode project, select `File` > `Swift Packages` > `Add Package Dependency` and enter the repository URL.

## Documentation

- [Basic Usage](#basic-usage)
- [Effects](#effects)
- [Middleware](#middleware)
- [Combine Reducers](#combine-reducers)

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

6\. Observe the store.

The store conforms to `Observable`. Store state can automatically be observed by SwiftUI views.

```swift
struct ContentView: View {
  @Environment(Store<CounterState>.self) var store

  var body: some View {
      Text("Counter: \(store.state.counter)")
      .onTapGesture {
          store.dispatch(CounterAction.increment)
      }
  }
}
```

### Effects

Normal actions don't allow for side effects like making a network call or accessing the disk. Effects allow you to perform asynchronous operations with side effects. Effects are not passed through the middleware pipeline and never reach the reducer but can dispatch other actions and even effects.

A synchronous effect can access state and dispatch other actions.

```swift
let store = Store(reducer: CounterState.reducer, initialState: CounterState(count: 0, name: ""))

let effect = Effect<CounterState> { dispatch, getState in
    dispatch(CounterAction.increment)
}

store.dispatch(effect)
```

An asynchronous effect can access state and dispatch other actions.

```swift
func getName() async throws -> String {
    let url = URL(string: "https://api.counter.com/name")!
    let (data, _) = try await URLSession.shared.data(from: url)
    return String(data: data, encoding: .utf8) ?? ""
}

let store = Store(reducer: CounterState.reducer, initialState: CounterState(count: 0, name: ""))

let effect = AsyncEffect<CounterState> { dispatch, _ in
    let name = try? await getName()
    await MainActor.run {
        dispatch(CounterAction.loadedName(name ?? ""))
    }
}

store.dispatch(effect)
```

### Middleware

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

## License

Reflow is available under the MIT license. See the [LICENSE](LICENSE) file for more info.
