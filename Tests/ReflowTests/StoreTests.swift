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
}
