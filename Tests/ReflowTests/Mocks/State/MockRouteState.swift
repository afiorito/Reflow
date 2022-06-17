@testable import Reflow

struct MockRouteState: Equatable {
    let route: String

    static func reducer(state: Self, action: any Action) -> Self {
        switch action {
            case let MockRouteAction.set(route):
                return Self(route: route)
            default:
                return state
        }
    }
}

enum MockRouteAction: Action {
    case set(String)
    case setIndex(Int)
}
