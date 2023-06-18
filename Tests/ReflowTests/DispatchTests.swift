import Combine
import XCTest
@testable import Reflow

final class DispatchTests: XCTestCase {
    var store: Store<MockCounterState>!

    override func setUp() {
        super.setUp()

        store = Store(reducer: MockCounterState.reducer, initialState: MockCounterState())
        MockCounterState.dispatchedActions.removeAll()
    }

    func testDispatchAction() {
        store.dispatch(MockCounterAction.increment)
        XCTAssertEqual(MockCounterState.dispatchedActions[0] as? MockCounterAction, MockCounterAction.increment)
        XCTAssertEqual(store.state.counter, 1)
    }

    func testDispatchSyncEffect() {
        store.dispatch(Effect<MockCounterState> { dispatch, _ in
            dispatch(MockCounterAction.increment)
        })
        XCTAssertEqual(store.state.counter, 1)
    }

    func testDispatchAsyncEffect() {
        let effectExpectation = expectation(description: "effect_dispatched")

        store.dispatch(AsyncEffect<MockCounterState> { dispatch, _ in
            await MainActor.run {
                dispatch(MockCounterAction.increment)
            }
            effectExpectation.fulfill()
        })

        wait(for: [effectExpectation], timeout: 10)
        XCTAssertEqual(store.state.counter, 1)
    }

    func testEffectDispatch() {
        store.dispatch(Effect<MockCounterState> { dispatch, _ in
            dispatch(MockCounterAction.loadCounterCompleted(100))
        })

        XCTAssertEqual(
            MockCounterState.dispatchedActions[0] as? MockCounterAction,
            MockCounterAction.loadCounterCompleted(100)
        )
        XCTAssertEqual(store.state.counter, 100)
    }

    func testEffectCanAccessState() {
        let effect = Effect<MockCounterState> { dispatch, getState in
            if getState().counter == 0 {
                dispatch(MockCounterAction.loadCounterCompleted(100))
            } else {
                dispatch(MockCounterAction.loadCounterCompleted(50))
            }
        }

        store.dispatch(effect)
        XCTAssertEqual(store.state.counter, 100)

        store.dispatch(effect)
        XCTAssertEqual(store.state.counter, 50)
    }
}
