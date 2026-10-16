import Foundation
import Testing
@testable import SbuSubscriptions

struct AppTabTests {
    @Test(arguments: [
        (AppRoute.calendar, AppTab.calendar),
        (.add, .subscriptions),
        (.subscription(UUID()), .subscriptions),
    ])
    func routeOpensItsTab(route: AppRoute, tab: AppTab) {
        #expect(AppTab(route) == tab)
    }
}
