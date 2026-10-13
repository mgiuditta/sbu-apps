import XCTest

/// Adds a timer from the bottom bar, checks the line on the player, then audits each screen.
final class TimerFlowTests: XCTestCase {
    @MainActor
    func testAddTimerShowsTheStatusLine() throws {
        let app = XCUIApplication()
        app.launchArguments = ["-AppleLanguages", "(it)", "-AppleLocale", "it_IT", "-lastCategory", "sounds"]
        app.launchEnvironment["SBU_NOISE_FILE"] = "ui-\(UUID().uuidString).json"
        app.launch()

        app.buttons["Timer"].tap()
        XCTAssertTrue(app.staticTexts["Nessun timer né sveglia"].waitForExistence(timeout: 2))
        try audit(app)

        app.buttons["Aggiungi"].tap()
        app.buttons["Nuovo timer"].tap()
        XCTAssertTrue(app.navigationBars["Nuovo timer"].waitForExistence(timeout: 2))
        try audit(app)
        app.buttons["Salva"].tap()

        XCTAssertTrue(app.staticTexts["30 min"].waitForExistence(timeout: 2))
        XCTAssertTrue(app.switches["30 min"].exists)
        try audit(app)

        app.buttons["Fine"].tap()
        XCTAssertTrue(app.buttons.matching(NSPredicate(format: "label BEGINSWITH 'Si ferma alle'")).firstMatch.waitForExistence(timeout: 2))
    }

    /// The same exclusions as the player flow: contrast comes from the tokens.
    @MainActor
    private func audit(_ app: XCUIApplication) throws {
        try app.performAccessibilityAudit(for: XCUIAccessibilityAuditType.all.subtracting([.contrast, .dynamicType])) { issue in
            XCTFail("\(issue.compactDescription): \(issue.element?.debugDescription ?? "no element")")
            return true
        }
    }
}
