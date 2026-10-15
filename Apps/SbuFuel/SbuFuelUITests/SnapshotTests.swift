import XCTest

/// Drives the App Store screenshots for `fastlane snapshot`, in Italian and English, on the sample car:
/// the figure, the history, the charts, maintenance, then the privacy promise in settings.
final class SnapshotTests: XCTestCase {
    @MainActor
    func testScreenshots() {
        let app = XCUIApplication()
        setupSnapshot(app)
        app.launch()

        XCTAssertTrue(app.descendants(matching: .any)["figure"].waitForExistence(timeout: 10))
        snapshot("01-main")

        app.buttons["history"].tap()
        snapshot("02-history")
        app.navigationBars.buttons.firstMatch.tap()

        app.buttons["costs"].tap()
        snapshot("03-costs")
        app.navigationBars.buttons.firstMatch.tap()

        app.buttons["services"].tap()
        snapshot("04-services")
        app.navigationBars.buttons.firstMatch.tap()

        let gear = app.navigationBars.buttons.matching(NSPredicate(format: "label IN %@", ["Impostazioni", "Settings"])).firstMatch
        XCTAssertTrue(gear.waitForExistence(timeout: 5))
        gear.tap()
        snapshot("05-privacy")
    }
}
