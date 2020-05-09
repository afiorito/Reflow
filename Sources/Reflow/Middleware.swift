import Foundation

/// A representation of a middleware function.
///
/// Middleware compose a dispatch function to return a new dispatch function.
public typealias Middleware<State> = (@escaping Dispatch, @escaping () -> State) -> (@escaping Dispatch) -> Dispatch
