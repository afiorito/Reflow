@testable import Reflow

struct MockState: Equatable {
    var route = MockRouteState(route: "Home")
    var status = MockStatusState(online: true)
}
