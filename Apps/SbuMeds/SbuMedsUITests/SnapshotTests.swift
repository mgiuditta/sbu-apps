import XCTest

/// Drives the App Store screenshots for `fastlane snapshot` on the made-up family
/// (`-FASTLANE_SNAPSHOT YES`, clock stopped at 10:12): today, a dose card, the family's
/// medicines, a medicine with its stock and history, then the privacy promise in settings.
final class SnapshotTests: XCTestCase {
    @MainActor
    func testScreenshots() {
        let app = XCUIApplication()
        setupSnapshot(app)
        app.launch()

        let dose = app.buttons.matching(identifier: "dose").firstMatch
        XCTAssertTrue(dose.waitForExistence(timeout: 5))
        snapshot("01-today")

        let late = app.buttons.matching(NSPredicate(format: "identifier == 'dose' AND (label BEGINSWITH 'Ferro' OR label BEGINSWITH 'Iron')")).firstMatch
        (late.exists ? late : dose).tap()
        XCTAssertTrue(app.buttons["markSkipped"].waitForExistence(timeout: 5) || app.buttons["unmark"].exists)
        snapshot("02-dose")
        app.buttons["closeDose"].tap()

        app.buttons["medicines"].tap()
        let medicine = app.buttons.matching(NSPredicate(format: "identifier == 'medicine' AND label BEGINSWITH 'Levot'")).firstMatch
        XCTAssertTrue(medicine.waitForExistence(timeout: 5))
        snapshot("03-medicines")

        medicine.tap()
        XCTAssertTrue(app.buttons["editMedicine"].waitForExistence(timeout: 5))
        snapshot("04-medicine")

        app.navigationBars.buttons.firstMatch.tap()
        app.navigationBars.buttons.firstMatch.tap()
        XCTAssertTrue(app.buttons["medicines"].waitForExistence(timeout: 5))
        app.navigationBars.buttons.element(boundBy: 1).tap()
        snapshot("06-privacy")
    }
}
