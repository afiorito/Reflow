import Combine
import Foundation
import Observation

/// A container for managing state using Combine. Manages functionality for dispatching actions/effects,
/// running middleware, executing reducers and publishing the latest state.
///
/// The ``Store`` class is not thread-safe, all changes to the store's state must be done on the same thread.
@Observable
public final class Store<State> {
    /// A dispatch function.
    ///
    /// Actions are dispatched to modify the state.
    public typealias Dispatch = (any Action) -> Void

    /// The current state of the store.
    ///
    /// This property should only be mutated by actions, never directly.
    public private(set) var state: State {
        get {
            access(keyPath: \.state)
            return _state
        }
        set {
            withMutation(keyPath: \.state) {
                _state = newValue
            }
        }
    }

    private let reducer: Reducer<State>

    @ObservationIgnored
    private var _state: State!

    @ObservationIgnored
    private var dispatcher: Dispatch! = nil

    @ObservationIgnored
    private var effectDispatcher: Dispatch! = nil

    @ObservationIgnored
    private lazy var middleware: [Middleware<State>] = [createEffectMiddleware()]

    /// Creates a store with initial state and middleware.
    ///
    /// - Parameters:
    ///     - reducer: A reducer which handles generating new state for all dispatched actions.
    ///     - initialState: The state before any actions are dispatched.
    ///     - middleware: The middleware that process an action prior to reaching the reducer.
    public init(reducer: @escaping Reducer<State>, initialState: State, middleware: [Middleware<State>] = []) {
        _state = initialState
        self.reducer = reducer
        self.middleware += middleware
        dispatcher = createDispatcher(initialState: initialState)
        threadCheck(event: .`init`)
    }

    /// Dispatches an ``Action``. Sends the action through the middleware pipeline and calls the reducer
    /// with the provided action and previous state to generate a new state.
    ///
    /// - Parameters:
    ///     - action: An action to be dispatched.
    public func dispatch(_ action: any Action) {
        dispatcher(action)
    }

    /// Generates a new version of the state by calling the reducer with the current state and an `action`.
    ///
    /// - Parameters:
    ///     - action: An action dispatched to the store.
    private func reduce(_ action: any Action) {
        threadCheck(event: .reduce)
        state = reducer(_state, action)
    }

    /// Returns a new dispatch function that wraps a dispatch with all registered middleware.
    ///
    /// - Parameters:
    ///     - initialState: The initial state passed during initialization.
    /// - Returns: A dispatch function wrapped with registered middleware.
    private func createDispatcher(initialState: State) -> Dispatch {
        middleware.reversed().reduce({ [weak self] action in self?.reduce(action) }, { dispatcher, middleware in
            let dispatch: Dispatch = { [weak self] in self?.dispatch($0) }
            let getState = { [weak self] in self?._state ?? initialState }
            return middleware(dispatch, getState)(dispatcher)
        })
    }

    /// Returns a middleware for executing a dispatched effect block.
    private func createEffectMiddleware() -> Middleware<State> {
        { dispatch, getState in
            { next in
                { action in
                    switch action {
                        case let action as Effect<State>:
                            action.block(dispatch, getState)
                        case let action as AsyncEffect<State>:
                            Task {
                                await action.block(dispatch, getState)
                            }
                        default:
                            next(action)
                    }
                }
            }
        }
    }
}

// MARK: - Thread checker

extension Store {
    enum StoreEvent {
        case `init`
        case reduce
    }

    @inline(__always)
    func threadCheck(event: StoreEvent) {
        #if DEBUG
            guard !Thread.isMainThread else { return }

            let action = switch event {
                case .`init`:
                "Store.init(reducer:initialState:middleware:)"
                case .reduce:
                "Store.reduce(action:)"
            }

            NSLog(
                """
                [Reflow] \
                \(action) called on a non-main thread. \
                The "Store" class is not thread-safe, all changes to the store's state must be done on the same thread.
                """
            )
        #endif
    }
}
