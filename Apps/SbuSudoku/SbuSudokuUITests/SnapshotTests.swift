import XCTest

/// Drives the App Store screenshots for `fastlane snapshot`: a game, then the settings.
final class SnapshotTests: XCTestCase {
    @MainActor
    func testScreenshots() {
        let app = XCUIApplication()
        setupSnapshot(app)
        app.launchArguments += ["-resetForUITests", "-newGame", "medium"]
        app.launch()
        XCTAssertTrue(app.otherElements["Punteggio 0"].waitForExistence(timeout: 5))

        snapshot("01-main")

        app.buttons["Impostazioni"].tap()
        snapshot("02-settings")
    }
}
