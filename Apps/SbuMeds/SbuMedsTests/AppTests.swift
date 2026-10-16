import Foundation
import Testing
@testable import SbuMeds

struct AppTests {
    @Test func bundleIdentifierFollowsTheSbuScheme() {
        #expect(Bundle.main.bundleIdentifier == "dev.sbu.meds")
    }
}
