import Foundation
import Testing
@testable import SbuTidy

struct AppTests {
    @Test func bundleIdentifierFollowsTheSbuScheme() {
        #expect(Bundle.main.bundleIdentifier == "dev.sbu.tidy")
    }
}
