import Foundation
import Testing
@testable import SbuSquares

struct AppTests {
    @Test func bundleIdentifierFollowsTheSbuScheme() {
        #expect(Bundle.main.bundleIdentifier == "dev.sbu.squares")
    }
}
