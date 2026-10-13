import XCTest

/// Adds an alarm from Timer, checks the line on the player; then a ringing alarm, stopped from
/// its screen. Audits each screen.
final class AlarmFlowTests: XCTestCase {
    @MainActor
    func testAddAnAlarm() throws {
        let app = launch()

        app.buttons["Timer"].tap()
        app.buttons["Aggiungi"].tap()
        app.buttons["Nuova sveglia"].tap()
        XCTAssertTrue(app.navigationBars["Nuova sveglia"].waitForExistence(timeout: 2))
        XCTAssertTrue(app.staticTexts["La sveglia suona se Noise resta aperta con un suono attivo. Altrimenti arriva una notifica."].exists)
        try audit(app)

        app.buttons.matching(NSPredicate(format: "label BEGINSWITH 'Suono'")).firstMatch.tap()
        XCTAssertTrue(app.navigationBars["Suono"].waitForExistence(timeout: 2))
        try audit(app)
        app.buttons["Sveglia classica"].tap()
        app.navigationBars["Suono"].buttons.firstMatch.tap()

        app.buttons["Salva"].tap()
        XCTAssertTrue(app.staticTexts["Sveglie"].waitForExistence(timeout: 2))
        XCTAssertTrue(app.staticTexts.matching(NSPredicate(format: "label CONTAINS 'Sveglia classica'")).firstMatch.exists)
        try audit(app)

        app.buttons["Fine"].tap()
        XCTAssertTrue(app.buttons.matching(NSPredicate(format: "label BEGINSWITH 'Sveglia alle'")).firstMatch.waitForExistence(timeout: 2))
    }

    @MainActor
    func testARingingAlarmStops() throws {
        let app = launch(ringing: true)

        XCTAssertTrue(app.buttons["Ferma"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.buttons["Rimanda di 9 minuti"].exists)
        try audit(app)
        app.buttons["Ferma"].tap()
        XCTAssertTrue(app.buttons["Riproduci"].waitForExistence(timeout: 2), "Back on the player, silent")
    }

    @MainActor
    private func launch(ringing: Bool = false) -> XCUIApplication {
        let app = XCUIApplication()
        app.launchArguments = ["-AppleLanguages", "(it)", "-AppleLocale", "it_IT", "-lastCategory", "sounds"]
        app.launchEnvironment["SBU_NOISE_FILE"] = "ui-\(UUID().uuidString).json"
        app.launchEnvironment["SBU_NOISE_BACKUP"] = "silent"
        if ringing { app.launchEnvironment["SBU_NOISE_RING"] = "1" }
        app.launch()
        return app
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
