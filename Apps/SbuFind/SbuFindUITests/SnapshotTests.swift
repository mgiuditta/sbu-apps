import XCTest

/// Drives the App Store screenshots for `fastlane snapshot`, with the demo devices
/// (`-FASTLANE_SNAPSHOT YES`): the list, the finder on the closest device, help with the limits,
/// then the privacy promise in settings.
final class SnapshotTests: XCTestCase {
    @MainActor
    func testScreenshots() {
        let app = XCUIApplication()
        setupSnapshot(app)
        app.launchArguments += ["-showsUnnamed", "NO"]
        app.launch()

        let row = app.buttons.matching(identifier: "device").firstMatch
        XCTAssertTrue(row.waitForExistence(timeout: 5))
        snapshot("01-list")

        row.tap()
        XCTAssertTrue(app.descendants(matching: .any).matching(identifier: "figure").firstMatch.waitForExistence(timeout: 5))
        snapshot("02-finder")
        app.navigationBars.buttons.firstMatch.tap()

        app.navigationBars.buttons.element(boundBy: 1).tap()
        snapshot("03-help")
        app.swipeDown(velocity: .fast)

        XCTAssertTrue(row.waitForExistence(timeout: 5))
        app.navigationBars.buttons.element(boundBy: 0).tap()
        snapshot("04-privacy")
    }
}
