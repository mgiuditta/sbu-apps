import Foundation
import Testing
@testable import SbuLibretto

struct AppTests {
    @Test func bundleIdentifierFollowsTheSbuScheme() {
        #expect(Bundle.main.bundleIdentifier == "dev.sbu.libretto")
    }
}
