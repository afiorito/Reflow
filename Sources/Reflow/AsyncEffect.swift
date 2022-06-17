/// A conformance of ``Action`` meant for logic with asynchronous side effects.
public struct AsyncEffect<State>: Action {
    /// The implementation of an ``AsyncEffect``.
    ///
    /// An effect block receives a `dispatch` and `getState` function.
    public typealias Block = (@escaping Dispatch, @escaping () -> State) async -> Void

    /// A block for encapsulating the logic of an ``AsyncEffect``.
    ///
    /// The block is called when dispatched to the store.
    public let block: Block

    /// Initializes an asynchronous effect.
    ///
    /// - Parameters:
    ///     - block: A block for encapsulating the logic of the effect.
    ///     The block is called when the effect is dispatched.
    public init(block: @escaping Block) {
        self.block = block
    }
}
