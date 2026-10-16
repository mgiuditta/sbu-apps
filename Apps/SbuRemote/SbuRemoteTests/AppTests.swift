import Foundation
import Testing
@testable import SbuRemote

struct AppTests {
    @Test func bundleIdentifierFollowsTheSbuScheme() {
        #expect(Bundle.main.bundleIdentifier == "dev.sbu.remote")
    }
}
