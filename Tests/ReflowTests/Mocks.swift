import Reflow
import XCTest

// MARK: - Counter

struct MockCounterState: Equatable {
    var counter = 0

    static func reducer(state: Self, action: Action) -> Self {
        state
    }

    static var dispatchedActions = [Action]()

    static func dispatchTrackingReducer(state: Self, action: Action) -> Self {
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

// MARK: - Route

struct MockRouteState: Equatable {
    var route: String

    static func reducer(state: Self, action: Action) -> Self {
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

// MARK: - Status

struct MockStatusState: Equatable {
    let online: Bool

    static func reducer(state: Self, action: Action) -> Self {
        state
    }
}

// MARK: - App

struct MockAppState: Equatable {
    var route = MockRouteState(route: "Home")
    var status = MockStatusState(online: true)
}

struct NoAction: Action {}

// MARK: - Middleware

var mockFirstMiddleware: Middleware<MockRouteState> = { _, _ in
    { next in
        { action in
            switch action {
                case let MockRouteAction.set(route):
                    next(MockRouteAction.set(route + " FIRST"))
                default:
                    next(action)
            }
        }
    }
}

var mockSecondMiddleware: Middleware<MockRouteState> = { _, _ in
    { next in
        { action in
            switch action {
                case let MockRouteAction.set(route):
                    next(MockRouteAction.set(route + " SECOND"))
                default:
                    next(action)
            }
        }
    }
}

let mockDispatchingMiddleware: Middleware<MockRouteState> = { dispatch, _ in
    { next in
        { action in
            switch action {
                case let MockRouteAction.setIndex(index):
                    dispatch(MockRouteAction.set("\(index)"))
                default:
                    break
            }

            next(action)
        }
    }
}

let mockStateAccessingMiddleware: Middleware<MockRouteState> = { dispatch, getState in
    { next in
        { action in
            // Stop recursion caused by dispatching the same action
            if case let MockRouteAction.set(route) = action, route != "BACK", getState().route == "FRONT" {
                dispatch(MockRouteAction.set("BACK"))

                // stop action from propagating
                next(NoAction())
            } else {
                next(action)
            }
        }
    }
}
