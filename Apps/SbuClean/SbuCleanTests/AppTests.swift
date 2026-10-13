import Foundation
import Testing
@testable import SbuClean

struct AppTests {
    @Test func bundleIdentifierFollowsTheSbuScheme() {
        #expect(Bundle.main.bundleIdentifier == "dev.sbu.clean")
    }
}
