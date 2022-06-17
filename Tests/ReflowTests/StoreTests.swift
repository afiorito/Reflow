import Combine
import XCTest
@testable import Reflow

final class StoreTests: XCTestCase {
    var sut: Store<MockCounterState>!
    var cancellable: AnyCancellable?

    override func setUp() {
        super.setUp()

        sut = Store(reducer: MockCounterState.reducer, initialState: MockCounterState())
    }

    func testStoreInit() {
        XCTAssertEqual(MockCounterState(), sut.state)
    }

    func testDispatch() {
        sut.dispatch(MockCounterAction.increment)
        XCTAssertEqual(sut.state, MockCounterState(counter: 1))
    }

    func testStoreSelect() {
        let valueExpectation = expectation(description: "value_received")
        cancellable = sut.select { state in
            state.counter
        }.sink { value in
            XCTAssertEqual(value, 0)
            valueExpectation.fulfill()
        }

        wait(for: [valueExpectation], timeout: 10)
    }
}
