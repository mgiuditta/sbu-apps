import XCTest

/// Drives the App Store screenshots for `fastlane snapshot`.
/// First the central figure, then the privacy promise in settings.
final class SnapshotTests: XCTestCase {
    @MainActor
    func testScreenshots() {
        let app = XCUIApplication()
        setupSnapshot(app)
        app.launch()

        snapshot("01-main")

        app.navigationBars.buttons.element(boundBy: 1).tap()  // 0 is Aggiungi, 1 the gear
        snapshot("02-privacy")
    }
}
