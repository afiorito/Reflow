import Combine

/// A container for managing state using Combine. Manages functionality for dispatching actions/effects,
/// running middleware, executing reducers and publishing the latest state.
open class Store<State> {
    public typealias Output = State
    public typealias Failure = Never
    public typealias Dispatch = (Action) -> Void
    public typealias EffectDispatch = (Effect<State>) -> AnyCancellable

    /// The current state of the store.
    @Published public private(set) var state: State

    /// Creates a store.
    ///
    /// - Parameters:
    ///     - reducer: A reducer which handles generating new state for all dispatched actions.
    ///     - initialState: The initial state before any actions are dispatched.
    ///     - middleware: The middleware that process an action prior to reaching the reducer.
    public init(reducer: @escaping Reducer<State>, initialState: State, middleware: [Middleware<State>] = []) {
        state = initialState
        self.reducer = reducer
        self.middleware += middleware
        dispatcher = createDispatcher(initialState: initialState)
        effectDispatcher = createEffectDispatch(initialState: initialState)
    }

    /// Dispatches an `action`. Sends the `action` through the middleware pipeline and calls the reducer
    /// with the provided action and previous state to generate a new state.
    ///
    /// - Parameters:
    ///     - action: An action to be dispatched.
    open func dispatch(_ action: Action) {
        dispatcher(action)
    }

    /// Executes the body of a dispatched `effect`.
    ///
    /// - Parameters:
    ///     - effect: An effect to be executed.
    /// - Returns: A cancellance instance for the effect.
    @discardableResult
    open func dispatch(_ effect: Effect<State>) -> AnyCancellable {
        effectDispatcher(effect)
    }

    /// Returns derived data from the state based on the provided `selector` function.
    ///
    /// - Parameters:
    ///     - selector: A transformation function for returning derived data from the state.
    /// - Returns: A publisher for the derived data specified in the `selector`.
    public func select<Prop: Equatable>(_ selector: @escaping (State) -> (Prop)) -> AnyPublisher<Prop, Never> {
        $state.map(selector).removeDuplicates().eraseToAnyPublisher()
    }

    /// Generates a new version of the state by calling the reducer with the current state and provided `action`.
    ///
    /// - Parameters:
    ///     - action: An action dispatched to the store.
    private func reduce(_ action: Action) {
        state = reducer(state, action)
    }

    /// Returns a new dispatch function that wraps a dispatch with all registered middleware.
    ///
    /// - Parameters:
    ///     - initialState: The initial state passed during initialization.
    /// - Returns: A dispatch function wrapped with registered middleware.
    private func createDispatcher(initialState: State) -> Dispatch {
        middleware.reversed().reduce({ [weak self] action in self?.reduce(action) }, { dispatcher, middleware in
            let dispatch: Dispatch = { [weak self] in self?.dispatch($0) }
            let getState = { [weak self] in self?.state ?? initialState }
            return middleware(dispatch, getState)(dispatcher)
        })
    }

    /// Returns a function for executing a dispatched effect block.
    ///
    /// - Parameters:
    ///     - initialState: The initial state passed during initialization.
    /// - Returns: A function for executing a dispatched effect block.
    private func createEffectDispatch(initialState: State) -> EffectDispatch {
        { [weak self] effect in
            let dispatch: Dispatch = { [weak self] in self?.dispatch($0) }
            return effect
                .block(dispatch) { [weak self] in self?.state ?? initialState } ??
                Empty(completeImmediately: true).sink {}
        }
    }

    /// Returns a middleware for executing a dispatched effect block.
    private func createEffectMiddleware() -> Middleware<State> {
        { [weak self] _, _ in
            { next in
                { action in
                    guard let effect = action as? Effect<State> else { return next(action) }
                    _ = self?.effectDispatcher(effect)
                }
            }
        }
    }

    private var dispatcher: Dispatch!
    private var effectDispatcher: EffectDispatch!
    private let reducer: Reducer<State>
    private lazy var middleware: [Middleware<State>] = [createEffectMiddleware()]
}
