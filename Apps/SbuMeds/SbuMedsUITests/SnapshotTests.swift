import XCTest

/// Drives the App Store screenshots for `fastlane snapshot` on the made-up family
/// (`-FASTLANE_SNAPSHOT YES`, clock stopped at 10:12): today, the family's
/// medicines, a medicine with its stock and history, the report for the doctor, then the privacy promise in settings.
final class SnapshotTests: XCTestCase {
    @MainActor
    func testScreenshots() {
        let app = XCUIApplication()
        setupSnapshot(app)
        app.launch()

        let dose = app.buttons.matching(identifier: "dose").firstMatch
        XCTAssertTrue(dose.waitForExistence(timeout: 5))
        snapshot("01-today")

        app.buttons["medicines"].tap()
        let medicine = app.buttons.matching(NSPredicate(format: "identifier == 'medicine' AND label BEGINSWITH 'Levot'")).firstMatch
        XCTAssertTrue(medicine.waitForExistence(timeout: 5))
        snapshot("02-medicines")

        medicine.tap()
        XCTAssertTrue(app.buttons["editMedicine"].waitForExistence(timeout: 5))
        snapshot("03-medicine")

        app.navigationBars.buttons.firstMatch.tap()
        app.buttons["report"].tap()
        XCTAssertTrue(app.descendants(matching: .any)["reportFigure"].waitForExistence(timeout: 10))
        snapshot("04-report")

        app.navigationBars.buttons.firstMatch.tap()
        app.navigationBars.buttons.firstMatch.tap()
        XCTAssertTrue(app.buttons["medicines"].waitForExistence(timeout: 5))
        app.navigationBars.buttons.element(boundBy: 1).tap()
        // Down to the promises at the end of settings.
        XCTAssertTrue(app.switches["remindersToggle"].waitForExistence(timeout: 5))
        app.swipeUp()
        snapshot("05-privacy")
    }
}
