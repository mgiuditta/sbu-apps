import XCTest

/// Drives the App Store screenshots for `fastlane snapshot`, in Italian and English, on the sample
/// libretto: the average, the study plan, the simulator, the next sittings, then the course rules.
final class SnapshotTests: XCTestCase {
    @MainActor
    func testScreenshots() {
        let app = XCUIApplication()
        setupSnapshot(app)
        // Without fastlane (a plain test run) the sample libretto comes from the same switch.
        app.launchArguments += ["-SBU_SAMPLE_STORE", "YES"]
        app.launch()

        XCTAssertTrue(app.descendants(matching: .any)["figure"].waitForExistence(timeout: 10))
        snapshot("01-main")

        app.buttons["studyPlan"].tap()
        XCTAssertTrue(app.buttons["addExam"].waitForExistence(timeout: 5))
        snapshot("02-plan")
        app.navigationBars.buttons.firstMatch.tap()

        app.buttons["simulate"].tap()
        XCTAssertTrue(app.steppers["nextCredits"].waitForExistence(timeout: 5))
        snapshot("03-simulator")
        app.navigationBars.buttons.firstMatch.tap()

        app.buttons["upcoming"].tap()
        XCTAssertTrue(app.buttons.matching(NSPredicate(format: "label IN %@", ["Sistemi operativi", "Operating Systems"])).firstMatch.waitForExistence(timeout: 5))
        snapshot("04-upcoming")
        app.navigationBars.buttons.firstMatch.tap()

        let gear = app.navigationBars.buttons.matching(NSPredicate(format: "label IN %@", ["Impostazioni", "Settings"])).firstMatch
        XCTAssertTrue(gear.waitForExistence(timeout: 5))
        gear.tap()
        XCTAssertTrue(app.buttons["cumLaudeValue"].waitForExistence(timeout: 5))
        app.swipeUp()
        snapshot("05-settings")
    }
}
