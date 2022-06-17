import Combine
import XCTest
@testable import Reflow

final class MiddlewareTests: XCTestCase {
    func testMiddlewareDispatcher() {
        let middleware = [
            mockFirstMiddleware,
            mockSecondMiddleware,
        ]

        let store = createStore(middleware: middleware)
        store.dispatch(MockRouteAction.set("HOME"))

        XCTAssertEqual(store.state.route, "HOME FIRST SECOND")
    }

    func testMiddlewareWithDispatch() {
        let middleware = [
            mockFirstMiddleware,
            mockSecondMiddleware,
            mockDispatchingMiddleware,
        ]

        let store = createStore(middleware: middleware)

        store.dispatch(MockRouteAction.setIndex(100))

        XCTAssertEqual(store.state.route, "100 FIRST SECOND")
    }

    func testMiddlewareWithGetState() {
        let store = createStore(initialState: "FRONT", middleware: [mockStateAccessingMiddleware])

        store.dispatch(MockRouteAction.set("Not Passed Through"))
        XCTAssertEqual(store.state.route, "BACK")
    }

    func testEffectMiddleware() {
        var isEffectCalled = false
        let effect = Effect<MockRouteState> { _, _ in
            isEffectCalled = true
        }

        let store = createStore()
        store.dispatch(effect)
        XCTAssertTrue(isEffectCalled)
    }

    func testEffectGetState() {
        var effectValue: String?
        let effect = Effect<MockRouteState> { _, getState in
            effectValue = getState().route
        }

        let store = createStore()
        store.dispatch(effect)
        XCTAssertEqual(effectValue, "")
    }

    func testEffectMiddlewareAsync() {
        let effectCalledExpectation = expectation(description: "effect_called")
        let effect = AsyncEffect<MockRouteState> { _, _ in
            try? await Task.sleep(nanoseconds: 0)
            effectCalledExpectation.fulfill()
        }

        let store = createStore()
        store.dispatch(effect)
        wait(for: [effectCalledExpectation], timeout: 10)
    }

    func testEffectDispatchEffect() {
        let store = createStore()

        store.dispatch(Effect<MockRouteState> { dispatch, _ in
            dispatch(MockRouteAction.set("action"))
        })
        XCTAssertEqual(store.state.route, "action")

        store.dispatch(Effect<MockRouteState> { dispatch, _ in
            dispatch(Effect<MockRouteState> { dispatch, _ in
                dispatch(MockRouteAction.set("effect"))
            })
        })
        XCTAssertEqual(store.state.route, "effect")

        let asyncEffectCalledExpectation = expectation(description: "async_effect_called")
        store.dispatch(Effect<MockRouteState> { dispatch, _ in
            dispatch(AsyncEffect<MockRouteState> { _, _ in
                asyncEffectCalledExpectation.fulfill()
            })
        })
        wait(for: [asyncEffectCalledExpectation], timeout: 10)
    }
}

extension MiddlewareTests {
    func createStore(initialState: String = "",
                     middleware: [Middleware<MockRouteState>] = []) -> Store<MockRouteState> {
        Store(
            reducer: MockRouteState.reducer,
            initialState: MockRouteState(route: initialState),
            middleware: middleware
        )
    }
}
