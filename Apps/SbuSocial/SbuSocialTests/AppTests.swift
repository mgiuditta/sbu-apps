import Foundation
import Testing
@testable import SbuSocial

struct AppTests {
    @Test func bundleIdentifierFollowsTheSbuScheme() {
        #expect(Bundle.main.bundleIdentifier == "dev.sbu.social")
    }
}
