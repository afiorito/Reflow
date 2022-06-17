@testable import Reflow

struct MockStatusState: Equatable {
    let online: Bool

    static func reducer(state: Self, action: any Action) -> Self {
        state
    }
}
