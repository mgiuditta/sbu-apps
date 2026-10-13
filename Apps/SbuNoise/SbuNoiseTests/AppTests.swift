import Foundation
import Testing
@testable import SbuNoise

struct AppTests {
    @Test func bundleIdentifierFollowsTheSbuScheme() {
        #expect(Bundle.main.bundleIdentifier == "dev.sbu.noise")
    }
}
