import Foundation
import Testing
@testable import SbuDuo

struct AppTests {
    @Test func bundleIdentifierFollowsTheSbuScheme() {
        #expect(Bundle.main.bundleIdentifier == "dev.sbu.duo")
    }
}
