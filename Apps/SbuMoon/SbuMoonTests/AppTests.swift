import Foundation
import Testing
@testable import SbuMoon

struct AppTests {
    @Test func bundleIdentifierFollowsTheSbuScheme() {
        #expect(Bundle.main.bundleIdentifier == "dev.sbu.moon")
    }
}
