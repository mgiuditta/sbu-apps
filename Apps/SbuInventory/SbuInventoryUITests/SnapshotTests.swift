import XCTest

/// Drives the App Store screenshots for `fastlane snapshot`, on the sample house:
/// the total, a folder, an item, then the privacy promise in settings.
final class SnapshotTests: XCTestCase {
    @MainActor
    func testScreenshots() {
        let app = XCUIApplication()
        setupSnapshot(app)
        app.launch()

        snapshot("01-main")

        app.element("folder-Casa").tap()
        app.element("folder-Garage").tap()
        snapshot("02-folder")

        app.element("item-Pile AA").tap()
        snapshot("03-item")

        app.navigationBars.buttons.element(boundBy: 0).tap()
        app.navigationBars.buttons.element(boundBy: 0).tap()
        app.navigationBars.buttons.element(boundBy: 0).tap()
        app.navigationBars.buttons["Impostazioni"].tap()
        snapshot("04-privacy")
    }
}
