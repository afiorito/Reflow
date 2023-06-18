@testable import Reflow

struct MockCounterState: Equatable {
    var counter: Int = 0

    init(counter: Int = 0) {
        self.counter = counter
    }

    static func reducer(state: Self, action: any Action) -> Self {
        dispatchedActions.append(action)

        var newState = state
        switch action {
            case MockCounterAction.increment:
                newState.counter += 1
            case let MockCounterAction.loadCounterCompleted(value):
                newState.counter = value
            default:
                return state
        }

        return newState
    }

    static var dispatchedActions = [any Action]()
}

enum MockCounterAction: Action, Equatable {
    case increment
    case loadCounterCompleted(Int)
}
