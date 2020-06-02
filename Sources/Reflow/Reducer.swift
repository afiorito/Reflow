import Foundation

/// A representation of a reducer function.
///
/// Reducers are pure functions that receive state and an action to return new state.
public typealias Reducer<State> = (State, Action) -> State

/// A helper function for combining multiple reducers into a single reducer. The reducers must reduce
/// the same type of state.
///
/// - Parameters:
///     - reducers: The reducers to be combined.
/// - Returns: A single reducer that returns the same type of state.
public func combineReducers<State>(_ reducers: Reducer<State>...) -> Reducer<State> {
    { state, action in
        (reducers.reduce(state) { accumulatedState, reducer in
            reducer(accumulatedState, action)
        })
    }
}

/// Convert a reducer returning a part of the state into a reducer returning the entire state.
///
/// - Parameters:
///     - keyPath: The key representing the substate property of the entire state.
///     - reducer: The reducer for the given substate.
/// - Returns: A reducer that returns the entire state.
public func withKey<State, SubState>(_ keyPath: WritableKeyPath<State, SubState>,
                                     use reducer: @escaping Reducer<SubState>) -> Reducer<State> {
    { state, action in
        var state = state
        state[keyPath: keyPath] = reducer(state[keyPath: keyPath], action)
        return state
    }
}
