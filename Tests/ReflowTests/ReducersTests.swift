import XCTest
@testable import Reflow

final class ReducersTests: XCTestCase {
    func testWithKey() {
        let mockStatusState = MockStatusState(online: false)
        let appStateReducer: Reducer<MockState> = withKey(\.status) { _, _ in mockStatusState }

        XCTAssertEqual(appStateReducer(MockState(), Noop()).status, mockStatusState)
    }

    func testCombineReducers() {
        var reducer1Called = false
        var reducer2Called = false
        let mockStatusState = MockStatusState(online: false)
        let mockRouteState = MockRouteState(route: "none")
        let reducers: Reducer<MockState> = combineReducers(
            withKey(\.status) { _, _ in
                reducer1Called = true
                return mockStatusState
            },
            withKey(\.route) { _, _ in
                reducer2Called = true
                return mockRouteState
            }
        )

        let store = Store(reducer: reducers, initialState: MockState())
        store.dispatch(Noop())
        XCTAssertEqual(store.state.status, mockStatusState)
        XCTAssertEqual(store.state.route, mockRouteState)
        XCTAssertTrue(reducer1Called)
        XCTAssertTrue(reducer2Called)
    }
}
