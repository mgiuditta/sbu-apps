import Foundation
import Testing
@testable import Sbu__NAME__

struct AppTests {
    @Test func bundleIdentifierFollowsTheSbuScheme() {
        #expect(Bundle.main.bundleIdentifier == "dev.sbu.__LOWER__")
    }
}
