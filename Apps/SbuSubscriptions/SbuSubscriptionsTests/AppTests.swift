import Foundation
import Testing
@testable import SbuSubscriptions

struct AppTests {
    @Test func bundleIdentifierFollowsTheSbuScheme() {
        #expect(Bundle.main.bundleIdentifier == "dev.sbu.subscriptions")
    }
}
