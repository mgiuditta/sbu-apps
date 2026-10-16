import Foundation
import Testing
@testable import SbuShrink

struct AppTests {
    @Test func bundleIdentifierFollowsTheSbuScheme() {
        #expect(Bundle.main.bundleIdentifier == "dev.sbu.shrink")
    }
}
