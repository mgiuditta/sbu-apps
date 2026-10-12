import Foundation
import Testing
@testable import SbuHabits

struct AppTests {
    @Test func bundleIdentifierFollowsTheSbuScheme() {
        #expect(Bundle.main.bundleIdentifier == "dev.sbu.habits")
    }
}
