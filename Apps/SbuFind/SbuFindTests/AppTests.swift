import Foundation
import Testing
@testable import SbuFind

struct AppTests {
    @Test func bundleIdentifierFollowsTheSbuScheme() {
        #expect(Bundle.main.bundleIdentifier == "dev.sbu.find")
    }
}
