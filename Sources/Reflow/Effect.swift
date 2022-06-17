/// A conformance of ``Action`` meant for logic with synchronous side effects.
public struct Effect<State>: Action {
    /// The implementation of an ``Effect``.
    ///
    /// An effect block receives a `dispatch` and `getState` function.
    public typealias Block = (@escaping Dispatch, @escaping () -> State) -> Void

    /// A block for encapsulating the logic of an ``Effect``.
    ///
    /// The block is called when dispatched to the store.
    public let block: Block

    /// Initializes a synchronous effect.
    ///
    /// - Parameters:
    ///     - block: A block for encapsulating the logic of the effect.
    ///     The block is called when the effect is dispatched.
    public init(block: @escaping Block) {
        self.block = block
    }
}
