import XCTest

/// Drives the remote with the demo TV (`-demoTV`, debug builds only) and audits accessibility.
final class RemoteFlowTests: XCTestCase {
    override func setUp() {
        continueAfterFailure = false
    }

    @MainActor
    private func launch(_ language: String = "it", touchpad: Bool = false, textSize: String? = nil) -> XCUIApplication {
        let app = XCUIApplication()
        app.launchArguments = [
            "-demoTV", "-AppleLanguages", "(\(language))", "-AppleLocale", language == "it" ? "it_IT" : "en_US",
            "-navigationMode", touchpad ? "touchpad" : "dPad",
        ]
        if let textSize {
            app.launchArguments += ["-UIPreferredContentSizeCategoryName", textSize]
        }
        app.launch()
        return app
    }

    @MainActor
    func testKeysAreLabelledAndPass() throws {
        let app = launch()
        XCTAssertTrue(app.buttons["Soggiorno"].waitForExistence(timeout: 5))
        for label in ["Home", "Accensione", "Su", "Giù", "Sinistra", "Destra", "OK", "Indietro",
                      "Riavvolgi", "Riproduci o metti in pausa", "Avanti veloce", "Rivedi", "Opzioni",
                      "Alza il volume", "Abbassa il volume", "Silenzia", "Canale successivo", "Canale precedente", "Sorgente"] {
            XCTAssertTrue(app.buttons[label].exists, "Missing key \(label)")
        }
        app.buttons["OK"].tap()
        app.buttons["Alza il volume"].press(forDuration: 1)
        try app.auditAccessibility()
    }

    @MainActor
    func testRemoteAtTheLargestTextSizePasses() throws {
        let app = launch(textSize: "UICTContentSizeCategoryAccessibilityXXXL")
        XCTAssertTrue(app.staticTexts["Telecomando"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.staticTexts["SBU · TELECOMANDO · SOGGIORNO"].exists)
        try app.auditAccessibility()
    }

    @MainActor
    func testTouchpadScreenPasses() throws {
        let app = launch(touchpad: true)
        XCTAssertTrue(app.buttons["Home"].waitForExistence(timeout: 5))
        XCTAssertFalse(app.buttons["Su"].exists)
        try app.auditAccessibility()
    }

    @MainActor
    func testKeyboardAppsAndSource() throws {
        let app = launch()
        app.buttons["Tastiera"].tap()
        let field = app.textFields["Scrivi sulla TV"]
        XCTAssertTrue(field.waitForExistence(timeout: 5))
        field.typeText("ciao")
        try app.auditAccessibility(dynamicType: false)
        app.buttons["Fine"].tap()

        app.buttons["App"].tap()
        XCTAssertTrue(app.buttons["YouTube"].waitForExistence(timeout: 5))
        app.buttons["Fissa nella riga"].firstMatch.tap()
        try app.auditAccessibility(dynamicType: false)
        app.buttons["Fine"].tap()
        XCTAssertTrue(app.buttons["Netflix"].waitForExistence(timeout: 5), "The first app, pinned, in the remote's row")

        // The apps sheet must be gone before the next one can come up.
        XCTAssertTrue(app.navigationBars["App"].waitForNonExistence(timeout: 5))
        app.buttons["Sorgente"].tap()
        XCTAssertTrue(app.buttons["PlayStation"].waitForExistence(timeout: 5))
        app.buttons["PlayStation"].tap()
    }

    @MainActor
    func testSourceListsTheTVInputs() throws {
        let app = launch()
        XCTAssertTrue(app.buttons["Sorgente"].waitForExistence(timeout: 5))
        app.buttons["Sorgente"].tap()
        XCTAssertTrue(app.buttons["PlayStation"].waitForExistence(timeout: 5))
        try app.auditAccessibility(dynamicType: false)
        app.buttons["PlayStation"].tap()
    }

    @MainActor
    func testSettingsListTheTVAndForgetIt() throws {
        let app = launch()
        app.buttons["Impostazioni"].tap()
        let row = app.buttons["Soggiorno, Samsung"]
        XCTAssertTrue(row.waitForExistence(timeout: 5))
        row.tap()
        XCTAssertTrue(app.staticTexts["Accensione"].waitForExistence(timeout: 5))
        try app.auditAccessibility(dynamicType: false)
        let forget = app.buttons["Dimentica questa TV"]
        let original = forget.frame
        forget.tap()
        // The confirmation's own button, not the one that opened it.
        let confirm = app.buttons.matching(NSPredicate(format: "label == 'Dimentica questa TV'")).allElementsBoundByIndex
            .first { $0.isHittable && $0.frame != original }
        try XCTUnwrap(confirm).tap()
        app.buttons["Fine"].tap()
        XCTAssertTrue(app.buttons["Cerca la TV"].waitForExistence(timeout: 5))
        try app.auditAccessibility()
    }

    @MainActor
    func testEnglishLabels() throws {
        let app = launch("en")
        XCTAssertTrue(app.buttons["Power"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.buttons["Back"].exists)
        XCTAssertTrue(app.buttons["Volume up"].exists)
    }
}
