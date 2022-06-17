@testable import Reflow

struct MockCounterState: Equatable {
    let counter: Int

    init(counter: Int = 0) {
        self.counter = counter
    }

    static func reducer(state: Self, action: any Action) -> Self {
        switch action {
            case MockCounterAction.increment:
                return MockCounterState(counter: state.counter + 1)
            default:
                return state
        }
    }

    static var dispatchedActions = [any Action]()

    static func dispatchTrackingReducer(state: Self, action: any Action) -> Self {
        dispatchedActions.append(action)

        switch action {
            case MockCounterAction.increment:
                return Self(counter: state.counter + 1)
            case let MockCounterAction.loadCounterCompleted(value):
                return Self(counter: value)
            default:
                return state
        }
    }
}

enum MockCounterAction: Action, Equatable {
    case increment
    case loadCounterCompleted(Int)
}
