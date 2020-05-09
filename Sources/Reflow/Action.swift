import Combine

/// A protocol that all actions must implement.
public protocol Action {}

/// An implementation of `Action` meant for dispatching actions with side effects.
public struct Effect<State>: Action {
    public typealias EffectBlock<Type> = (@escaping Dispatch, @escaping () -> State) -> Type

    /// A function for encapsulating the logic of an `Effect`.
    ///
    /// The body is called when dispatching effects.
    public let block: EffectBlock<AnyCancellable>

    public init(block: @escaping EffectBlock<AnyCancellable>) {
        self.block = block
    }

    public init(block: @escaping EffectBlock<Void>) {
        self.block = { dispatch, getState in
            Just(block(dispatch, getState)).ignoreOutput().sink(receiveValue: {})
        }
    }

}
