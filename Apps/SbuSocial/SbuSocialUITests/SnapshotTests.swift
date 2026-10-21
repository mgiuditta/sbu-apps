import XCTest

/// Drives the App Store screenshots for `fastlane snapshot`.
/// First Home, the tab the app opens on, then the privacy promise in the Impostazioni tab.
final class SnapshotTests: XCTestCase {
    @MainActor
    func testScreenshots() {
        let app = XCUIApplication()
        setupSnapshot(app)
        app.launch()

        snapshot("01-main")

        app.tabBars.buttons.element(boundBy: 4).tap()
        snapshot("02-privacy")
    }
}
