import XCTest
import Combine
@testable import Reflow

final class DispatchTests: XCTestCase {

    var store: Store<MockCounterState>!
    var cancellable: AnyCancellable?

    override func setUp() {
        super.setUp()

        store = Store(reducer: MockCounterState.dispatchTrackingReducer, initialState: MockCounterState())
        MockCounterState.dispatchedActions.removeAll()
    }

    func testDispatchAction() {
        store.dispatch(MockCounterAction.increment)
        XCTAssertEqual(MockCounterState.dispatchedActions[0] as? MockCounterAction, MockCounterAction.increment)

        let valueExpectation = expectation(description: "value_received")
        cancellable = store.$state.sink { state in
            XCTAssertEqual(state.counter, 1)
            valueExpectation.fulfill()
        }

        wait(for: [valueExpectation], timeout: 10)
    }

    func testDispatchSyncEffect() {
        let valueExpectation = expectation(description: "value_received")
        store.dispatch(Effect<MockCounterState> { _, _ in
            valueExpectation.fulfill()
        })

        wait(for: [valueExpectation], timeout: 10)
    }

    let subject = PassthroughSubject<Int, Never>()

    func testDispatchAsyncEffect() {
        let effectExpectation = expectation(description: "effect_dispatched")
         store.dispatch(Effect<MockCounterState> { _, _ -> AnyCancellable in
            return Just(0).delay(for: .milliseconds(10), scheduler: RunLoop.main)
                .sink(receiveCompletion: { _ in
                    effectExpectation.fulfill()
                }, receiveValue: { _ in })
        })

        wait(for: [effectExpectation], timeout: 10)
    }

    func testEffectDispatch() {
        store.dispatch(Effect<MockCounterState> { dispatch, _ -> Void in
            dispatch(MockCounterAction.loadCounterCompleted(100))
        })

        XCTAssertEqual(MockCounterState.dispatchedActions[0] as? MockCounterAction, MockCounterAction.loadCounterCompleted(100))

        let valueExpectation = expectation(description: "value_received")
        cancellable = store.$state.sink { state in
            XCTAssertEqual(state.counter, 100)
            valueExpectation.fulfill()
        }

        wait(for: [valueExpectation], timeout: 10)
    }

    func testEffectCanAccessState() {
        store.dispatch(MockCounterAction.increment)
        XCTAssertEqual(MockCounterState.dispatchedActions[0] as? MockCounterAction, MockCounterAction.increment)

        store.dispatch(Effect<MockCounterState> { dispatch, getState -> Void in
            if getState().counter == 0 {
                dispatch(MockCounterAction.loadCounterCompleted(100))
            } else {
                dispatch(MockCounterAction.loadCounterCompleted(50))
            }
        })

        XCTAssertEqual(MockCounterState.dispatchedActions[1] as? MockCounterAction, MockCounterAction.loadCounterCompleted(50))

        let valueExpectation = expectation(description: "value_received")
        cancellable = store.$state.sink { state in
            XCTAssertEqual(state.counter, 50)
            valueExpectation.fulfill()
        }

        wait(for: [valueExpectation], timeout: 10)

    }
}
