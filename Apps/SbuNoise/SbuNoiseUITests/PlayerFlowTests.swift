import XCTest

/// Drives the player like a person would, then audits the screen for accessibility.
final class PlayerFlowTests: XCTestCase {
    @MainActor
    func testPlayNextInfoAndAudit() throws {
        let app = XCUIApplication()
        app.launchArguments = ["-AppleLanguages", "(it)", "-AppleLocale", "it_IT", "-lastSoundID", "noise.white", "-lastCategory", "sounds"]
        app.launchEnvironment["SBU_NOISE_FILE"] = "ui-\(UUID().uuidString).json"
        app.launch()

        XCTAssertTrue(figure(app, "Rumore bianco").waitForExistence(timeout: 5))
        app.buttons["Riproduci"].tap()
        XCTAssertTrue(app.buttons["Pausa"].waitForExistence(timeout: 2))

        app.buttons["Successivo"].tap()
        XCTAssertTrue(figure(app, "Rumore rosa").waitForExistence(timeout: 2))
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
        XCTAssertTrue(app.staticTexts["SBU · RUMORE · PREFERITI"].waitForExistence(timeout: 2))
        XCTAssertTrue(app.descendants(matching: .any)["Rumore rosa, 1 di 1"].exists)
        app.buttons["Togli dai preferiti"].tap()
        XCTAssertTrue(app.staticTexts["Tocca il cuore sotto un suono o un mix per ritrovarlo qui."].waitForExistence(timeout: 2))
        sleep(1)
        try audit(app)
    }

    /// The player at the largest text size: the figure keeps one line, the controls stay reachable.
    @MainActor
    func testLargestTextAudit() throws {
        let app = XCUIApplication()
        app.launchArguments = ["-AppleLanguages", "(it)", "-AppleLocale", "it_IT", "-lastSoundID", "noise.white", "-lastCategory", "sounds"]
        app.launchArguments += ["-UIPreferredContentSizeCategoryName", "UICTContentSizeCategoryAccessibilityXXXL"]
        app.launchEnvironment["SBU_NOISE_FILE"] = "ui-\(UUID().uuidString).json"
        app.launch()

        XCTAssertTrue(figure(app, "Rumore bianco").waitForExistence(timeout: 5))
        XCTAssertTrue(app.buttons["Riproduci"].isHittable)
        try audit(app)
    }

    /// The figure: one element, the name then its place in the list.
    @MainActor
    private func figure(_ app: XCUIApplication, _ name: String) -> XCUIElement {
        app.descendants(matching: .any).matching(NSPredicate(format: "label BEGINSWITH %@", name + ",")).firstMatch
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
