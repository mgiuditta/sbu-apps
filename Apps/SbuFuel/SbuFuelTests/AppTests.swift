import Foundation
import Testing
@testable import SbuFuel

struct AppTests {
    @Test func bundleIdentifierFollowsTheSbuScheme() {
        #expect(Bundle.main.bundleIdentifier == "dev.sbu.fuel")
    }
}
