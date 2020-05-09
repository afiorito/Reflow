/// A representation of a dispatch function.
///
/// Dispatch functions send actions to the store to be processed by middleware and reducers.
public typealias Dispatch = (Action) -> Void
