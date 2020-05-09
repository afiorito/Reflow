import XCTest
@testable import Reflow

final class CombineReducersTests: XCTestCase {
    func testWithKey() {
        let appStateReducer: Reducer<MockAppState> = withKey(\.status, use: MockStatusState.reducer)

        let state = MockAppState()
        XCTAssertEqual(appStateReducer(state, NoAction()), state)
    }

    func testCombineReducers() {
        let reducers: Reducer<MockAppState> = combineReducers(
            withKey(\.status, use: MockStatusState.reducer),
            withKey(\.route, use: MockRouteState.reducer)
        )

        let store = Store<MockAppState>(reducer: reducers, initialState: MockAppState())
        XCTAssertEqual(store.state.status, MockAppState().status)
        XCTAssertEqual(store.state.route, MockAppState().route)
    }
}
