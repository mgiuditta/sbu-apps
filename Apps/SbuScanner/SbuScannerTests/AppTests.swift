import Foundation
import Testing
@testable import SbuScanner

struct AppTests {
    /// The 2.0 updates the listing already on sale, so it keeps the 1.x bundle.
    @Test func bundleIdentifierIsTheOneOnTheAppStore() {
        #expect(Bundle.main.bundleIdentifier == "dev.sbu.barcodescanner")
    }
}
