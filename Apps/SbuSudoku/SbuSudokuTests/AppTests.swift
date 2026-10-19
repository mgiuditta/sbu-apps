import Foundation
import Testing
@testable import SbuSudoku

struct AppTests {
    @Test func bundleIdentifierFollowsTheSbuScheme() {
        #expect(Bundle.main.bundleIdentifier == "dev.sbu.sudoku")
    }
}
