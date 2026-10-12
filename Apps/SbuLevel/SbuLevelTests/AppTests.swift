import Foundation
import Testing
@testable import SbuLevel

struct AppTests {
    @Test func bundleIdentifierFollowsTheSbuScheme() {
        #expect(Bundle.main.bundleIdentifier == "dev.sbu.level")
    }
}
