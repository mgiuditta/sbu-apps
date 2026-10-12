import XCTest

/// Drives the App Store screenshots for `fastlane snapshot`.
/// First the tool screen with three demo habits, then the privacy promise in settings.
final class SnapshotTests: XCTestCase {
    @MainActor
    func testScreenshots() {
        let app = XCUIApplication()
        setupSnapshot(app)
        app.launch()

        XCTAssertTrue(app.descendants(matching: .any)["Leggere"].firstMatch.waitForExistence(timeout: 10) || app.descendants(matching: .any)["Read"].firstMatch.exists)
        snapshot("01-main")

        app.navigationBars.buttons.element(boundBy: 0).tap()
        snapshot("02-privacy")
    }
}
