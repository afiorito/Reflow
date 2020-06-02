import Combine
@testable import Reflow
import XCTest

final class StoreTests: XCTestCase {
    var store: Store<MockCounterState>!
    var cancellable: AnyCancellable?

    override func setUp() {
        super.setUp()

        store = Store(reducer: MockCounterState.reducer, initialState: MockCounterState())
    }

    func testStoreInit() {
        XCTAssertEqual(MockCounterState(), store.state)
    }

    func testStoreSelect() {
        let valueExpectation = expectation(description: "value_received")
        cancellable = store.select { state in
            state.counter
        }.sink { value in
            XCTAssertEqual(value, 0)
            valueExpectation.fulfill()
        }

        wait(for: [valueExpectation], timeout: 10)
    }
}
