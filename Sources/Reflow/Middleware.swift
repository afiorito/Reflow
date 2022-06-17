/// A representation of a middleware function.
///
/// Middleware intercept actions, manipulate them and pass them through the next middleware .
public typealias Middleware<State> = (@escaping Dispatch, @escaping () -> State) -> (@escaping Dispatch) -> Dispatch
