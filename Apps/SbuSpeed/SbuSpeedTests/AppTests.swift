import Foundation
import Testing
@testable import SbuSpeed

struct AppTests {
    @Test func bundleIdentifierFollowsTheSbuScheme() {
        #expect(Bundle.main.bundleIdentifier == "dev.sbu.speed")
    }
}
