import XCTest

/// Drives the App Store screenshots for `fastlane snapshot`, on the sample house:
/// the total, a folder, an item, then the privacy promise in settings.
///
/// The sample's names follow the language fastlane picks (Casa or Home), and a fresh simulator
/// without fastlane runs in English: every row is found by its name in either language.
final class SnapshotTests: XCTestCase {
    override func setUp() {
        continueAfterFailure = false
    }

    @MainActor
    func testScreenshots() {
        let app = XCUIApplication()
        setupSnapshot(app)
        app.launch()

        let home = row(["folder-Casa", "folder-Home"], in: app)
        XCTAssertTrue(home.waitForExistence(timeout: 10))
        snapshot("01-main")

        home.tap()
        let garage = row(["folder-Garage"], in: app)
        XCTAssertTrue(garage.waitForExistence(timeout: 5))
        garage.tap()
        let batteries = row(["item-Pile AA", "item-AA batteries"], in: app)
        XCTAssertTrue(batteries.waitForExistence(timeout: 5))
        snapshot("02-folder")

        batteries.tap()
        XCTAssertTrue(row(["quantity"], in: app).waitForExistence(timeout: 5))
        snapshot("03-item")

        for _ in 0..<3 {
            app.navigationBars.buttons.element(boundBy: 0).tap()
        }
        let settings = app.navigationBars.buttons.matching(NSPredicate(format: "label IN %@", ["Impostazioni", "Settings"])).firstMatch
        XCTAssertTrue(settings.waitForExistence(timeout: 5))
        settings.tap()
        snapshot("04-privacy")
    }

    /// The first element with one of these accessibility identifiers.
    private func row(_ identifiers: [String], in app: XCUIApplication) -> XCUIElement {
        app.descendants(matching: .any).matching(NSPredicate(format: "identifier IN %@", identifiers)).firstMatch
    }
}
