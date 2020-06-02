@testable import Reflow
import XCTest

final class MiddlewareTests: XCTestCase {
    func testMiddlewareDispatcher() {
        let middleware: [Middleware<MockRouteState>] = [
            mockFirstMiddleware,
            mockSecondMiddleware,
        ]

        let store = Store<MockRouteState>(reducer: MockRouteState.reducer, initialState: MockRouteState(route: ""),
                                          middleware: middleware)

        store.dispatch(MockRouteAction.set("HOME"))

        XCTAssertEqual(store.state.route, "HOME FIRST SECOND")
    }

    func testMiddlewareDispatch() {
        let middleware: [Middleware<MockRouteState>] = [
            mockFirstMiddleware,
            mockSecondMiddleware,
            mockDispatchingMiddleware,
        ]

        let store = Store<MockRouteState>(reducer: MockRouteState.reducer,
                                          initialState: MockRouteState(route: ""), middleware: middleware)

        store.dispatch(MockRouteAction.setIndex(100))

        XCTAssertEqual(store.state.route, "100 FIRST SECOND")
    }

    func testMiddlewareCanAccessState() {
        let store = Store<MockRouteState>(reducer: MockRouteState.reducer,
                                          initialState: MockRouteState(route: "FRONT"),
                                          middleware: [mockStateAccessingMiddleware])

        store.dispatch(MockRouteAction.set("Not Passed Through"))
        XCTAssertEqual(store.state.route, "BACK")
    }
}
