import XCTest

/// Drives the player like a person would, then audits the screen for accessibility.
final class PlayerFlowTests: XCTestCase {
    @MainActor
    func testPlayNextInfoAndAudit() throws {
        let app = XCUIApplication()
        app.launchArguments = ["-AppleLanguages", "(it)", "-AppleLocale", "it_IT", "-lastSoundID", "noise.white", "-lastCategory", "sounds"]
        app.launchEnvironment["SBU_NOISE_FILE"] = "ui-\(UUID().uuidString).json"
        app.launch()

        XCTAssertTrue(app.staticTexts["Rumore bianco"].waitForExistence(timeout: 5))
        app.buttons["Riproduci"].tap()
        XCTAssertTrue(app.buttons["Pausa"].waitForExistence(timeout: 2))

        app.buttons["Successivo"].tap()
        XCTAssertTrue(app.staticTexts["Rumore rosa"].waitForExistence(timeout: 2))
        XCTAssertTrue(app.buttons["Pausa"].exists, "Changing sound keeps playing")

        app.buttons["Aggiungi ai preferiti"].tap()
        XCTAssertTrue(app.buttons["Togli dai preferiti"].exists)

        try audit(app)

        app.buttons["Informazioni"].tap()
        XCTAssertTrue(app.staticTexts["Generato in tempo reale"].waitForExistence(timeout: 2))
        try audit(app)
        app.buttons["Fine"].tap()

        app.buttons["Categorie"].tap()
        app.buttons["Preferiti"].tap()
        XCTAssertTrue(app.staticTexts["Preferiti · 1 di 1"].waitForExistence(timeout: 2))
        XCTAssertTrue(app.staticTexts["Rumore rosa"].exists)
        app.buttons["Togli dai preferiti"].tap()
        XCTAssertTrue(app.staticTexts["Nessun preferito"].waitForExistence(timeout: 2))
        sleep(1)
        try audit(app)
    }

    /// Contrast comes from the tokens (checked by sync_tokens.py) and the figure is sized with
    /// @ScaledMetric, which the Dynamic Type audit does not recognize, as in the other apps.
    @MainActor
    private func audit(_ app: XCUIApplication) throws {
        try app.performAccessibilityAudit(for: XCUIAccessibilityAuditType.all.subtracting([.contrast, .dynamicType])) { issue in
            XCTFail("\(issue.compactDescription): \(issue.element?.debugDescription ?? "no element")")
            return true
        }
    }
}
