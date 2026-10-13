import XCTest

/// Creates a mix from Crea like in the original: choose sounds, arrange them on the Mix Pad, name
/// it; then it plays from its page in Mix. Audits each screen.
final class MixFlowTests: XCTestCase {
    @MainActor
    func testCreateAMixAndPlayIt() throws {
        let app = XCUIApplication()
        app.launchArguments = ["-AppleLanguages", "(it)", "-AppleLocale", "it_IT", "-lastCategory", "sounds"]
        app.launchEnvironment["SBU_NOISE_FILE"] = "ui-\(UUID().uuidString).json"
        app.launch()

        app.buttons["Crea"].tap()
        app.buttons["Nuovo mix"].tap()
        XCTAssertTrue(app.navigationBars["Scegli i suoni"].waitForExistence(timeout: 2))
        app.buttons["Rumore blu"].tap()
        app.buttons["Rumore rosa"].tap()
        try audit(app)
        app.buttons["Avanti"].tap()

        XCTAssertTrue(app.navigationBars["Mix Pad"].waitForExistence(timeout: 2))
        try audit(app)

        app.buttons["Rumore rosa"].tap()
        XCTAssertTrue(app.sliders["Varianza"].waitForExistence(timeout: 2))
        app.sliders["Varianza"].adjust(toNormalizedSliderPosition: 0.4)
        try audit(app)
        app.navigationBars["Rumore rosa"].buttons["Fine"].tap()

        app.navigationBars["Mix Pad"].buttons["Fine"].tap()
        XCTAssertTrue(app.alerts["Salva il mix"].waitForExistence(timeout: 2))
        app.alerts.buttons["Salva"].tap()

        XCTAssertTrue(app.staticTexts["Mix · 1 di 1"].waitForExistence(timeout: 2))
        XCTAssertFalse(app.navigationBars["Scegli i suoni"].exists, "Saving closes the whole sheet")
        XCTAssertTrue(app.buttons["Pausa"].exists, "The new mix plays")
        try audit(app)
        app.buttons["Pausa"].tap()
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
