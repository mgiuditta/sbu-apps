import Foundation
import Testing
@testable import SbuGrid

struct AppTests {
    @Test func bundleIdentifierFollowsTheSbuScheme() {
        #expect(Bundle.main.bundleIdentifier == "dev.sbu.grid")
    }
}
