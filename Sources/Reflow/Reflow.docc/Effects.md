# Effects

Create effects that can access state, dispatch actions/effects and create side effects.

## Overview

Normal actions don't allow for side effects like making a network call or accessing the disk. Effects allow you to perform operations that may cause side effects. The dispatched effects are not passed through the middleware pipeline and never reach the reducer but can dispatch other actions and even effects.

### Effect

A synchronous effect can access state and dispatch other actions.

```swift
let store = Store(reducer: CounterState.reducer, initialState: CounterState(count: 0, name: ""))

let effect = Effect<CounterState> { dispatch, getState in
    dispatch(CounterAction.increment)
}

store.dispatch(effect)
```

### AsyncEffect

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

    // always update the store on the main thread
    await MainActor.run {
        dispatch(CounterAction.loadedName(name ?? ""))
    }
}

store.dispatch(effect)
```
