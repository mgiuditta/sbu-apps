import XCTest

/// Drives the tool screen and the settings sheet, and runs the accessibility audit on both.
/// Runs in Italian with the fixed snapshot drive, so the simulator needs no GPS and shows no location prompt.
final class SpeedFlowTests: XCTestCase {
    override func setUp() {
        continueAfterFailure = false
    }

    @MainActor
    private func launch() -> XCUIApplication {
        let app = XCUIApplication()
        app.launchArguments += ["-AppleLanguages", "(it)", "-AppleLocale", "it_IT", "-FASTLANE_SNAPSHOT", "YES"]
        app.launch()
        return app
    }

    @MainActor
    func testToolScreenShowsTheSpeedAndTheTripAndPassesTheAccessibilityAudit() throws {
        let app = launch()

        let figure = app.staticTexts.matching(NSPredicate(format: "label BEGINSWITH 'Velocità'")).firstMatch
        XCTAssertTrue(figure.waitForExistence(timeout: 5))
        XCTAssertTrue(figure.label.contains("52"), figure.label)
        XCTAssertTrue(app.staticTexts.matching(NSPredicate(format: "label BEGINSWITH 'Massima'")).firstMatch.exists)
        XCTAssertTrue(app.buttons["Azzera viaggio"].isEnabled)

        // Contrast is left out as in Sbu Habits: text colors come from tokens with checked ratios,
        // and the audit misreads the iOS 26 glass bar and the dial's decorative track.
        try app.performAccessibilityAudit(for: XCUIAccessibilityAuditType.all.subtracting(.contrast)) { issue in
            XCTFail("\(issue.compactDescription): \(issue.element?.debugDescription ?? "no element")")
            return true
        }
    }

    @MainActor
    func testResetAsksBeforeClearingTheTrip() {
        let app = launch()
        let reset = app.buttons["Azzera viaggio"]
        XCTAssertTrue(reset.waitForExistence(timeout: 5))
        XCTAssertTrue(reset.isEnabled)

        reset.tap()

        // The confirmation repeats the action: the trip is cleared only after the second tap.
        let dialog = app.sheets.firstMatch
        let confirm = dialog.buttons["Azzera viaggio"]
        XCTAssertTrue(confirm.waitForExistence(timeout: 5))
        confirm.tap()
        XCTAssertTrue(dialog.waitForNonExistence(timeout: 5))

        let cleared = XCTNSPredicateExpectation(predicate: NSPredicate(format: "isEnabled == false"), object: reset)
        XCTAssertEqual(XCTWaiter.wait(for: [cleared], timeout: 5), .completed)
    }

    @MainActor
    func testSettingsOfferTheUnitAndPassTheAccessibilityAudit() throws {
        let app = launch()

        app.buttons["Impostazioni"].tap()
        XCTAssertTrue(app.staticTexts["La distanza segue la velocità: chilometri con km/h, miglia con mph, miglia nautiche con i nodi."].waitForExistence(timeout: 5))

        // Dynamic Type is left out as in Sbu Habits: in the settings sheet the audit flags every
        // text as partially unsupported, system ones included.
        try app.performAccessibilityAudit(for: XCUIAccessibilityAuditType.all.subtracting([.contrast, .dynamicType])) { issue in
            XCTFail("\(issue.compactDescription): \(issue.element?.debugDescription ?? "no element")")
            return true
        }
    }
}
