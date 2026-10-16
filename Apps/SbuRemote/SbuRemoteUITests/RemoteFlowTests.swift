import XCTest

/// Drives the remote with the demo TV (`-demoTV`, debug builds only) and audits accessibility.
final class RemoteFlowTests: XCTestCase {
    override func setUp() {
        continueAfterFailure = false
    }

    @MainActor
    private func launch(_ language: String = "it") -> XCUIApplication {
        let app = XCUIApplication()
        app.launchArguments = ["-demoTV", "-AppleLanguages", "(\(language))", "-AppleLocale", language == "it" ? "it_IT" : "en_US"]
        app.launch()
        return app
    }

    @MainActor
    func testKeysAreLabelledAndPass() throws {
        let app = launch()
        XCTAssertTrue(app.staticTexts["Soggiorno"].waitForExistence(timeout: 5))
        for label in ["Home", "Accensione", "Su", "Giù", "Sinistra", "Destra", "OK", "Indietro"] {
            XCTAssertTrue(app.buttons[label].exists, "Missing key \(label)")
        }
        app.buttons["OK"].tap()
        app.buttons["Su"].tap()
        try app.auditAccessibility()
    }

    @MainActor
    func testEnglishLabels() throws {
        let app = launch("en")
        XCTAssertTrue(app.buttons["Power"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.buttons["Back"].exists)
    }
}
