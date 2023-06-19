import XCTest
@testable import Reflow

var mockFirstMiddleware: Middleware<MockRouteState> = { _, _ in { next in { action in
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
            } else {
                next(action)
            }
        }
    }
}
