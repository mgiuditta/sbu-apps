import XCTest

/// Gestisci from the bottom bar: search, hide a sound and put it back, play one with a tap;
/// then the ☰ groups and the bedside clock. Audits each screen.
final class ManageFlowTests: XCTestCase {
    @MainActor
    func testManageTheCatalog() throws {
        let app = launch()

        app.buttons["Gestisci"].tap()
        XCTAssertTrue(app.navigationBars["Gestisci"].waitForExistence(timeout: 2))
        try audit(app)

        let rosa = app.buttons.matching(NSPredicate(format: "label BEGINSWITH 'Rumore rosa'")).firstMatch
        rosa.swipeLeft()
        app.buttons["Nascondi"].tap()

        // The hidden sounds are at the bottom of a long list: the search finds them.
        let search = app.searchFields.firstMatch
        search.tap()
        search.typeText("rosa")
        let hidden = app.buttons.matching(NSPredicate(format: "label BEGINSWITH 'Rumore rosa' AND label CONTAINS 'Nascosto'")).firstMatch
        XCTAssertTrue(hidden.waitForExistence(timeout: 2))
        hidden.tap()
        XCTAssertTrue(app.buttons.matching(NSPredicate(format: "label BEGINSWITH 'Rumore rosa' AND NOT label CONTAINS 'Nascosto'")).firstMatch.waitForExistence(timeout: 2), "A tap puts a hidden sound back")

        search.buttons.firstMatch.tap() // Clear text
        search.typeText("vento")
        let vento = app.buttons.matching(NSPredicate(format: "label BEGINSWITH 'Vento'")).firstMatch
        // No audit while typing: the keyboard's own suggestion bar has no labels.
        XCTAssertTrue(vento.waitForExistence(timeout: 2))
        vento.tap()

        XCTAssertTrue(app.descendants(matching: .any).matching(NSPredicate(format: "label BEGINSWITH 'Vento,'")).firstMatch.waitForExistence(timeout: 2))
        XCTAssertTrue(app.buttons["Pausa"].exists, "A tap in Gestisci plays the sound")
        app.buttons["Pausa"].tap()
    }

    @MainActor
    func testGroupsAndBedsideClock() throws {
        let app = launch()

        app.buttons["Categorie"].tap()
        app.buttons["Natura"].tap()
        XCTAssertTrue(app.staticTexts["SBU · RUMORE · NATURA"].waitForExistence(timeout: 2))
        XCTAssertTrue(app.descendants(matching: .any).matching(NSPredicate(format: "label CONTAINS ', 1 di '")).firstMatch.exists)
        try audit(app)

        app.buttons["Dormi"].tap()
        XCTAssertTrue(app.staticTexts["Nessuna sveglia"].waitForExistence(timeout: 2))
        XCTAssertTrue(app.sliders["Luminosità"].exists)
        try audit(app)
        app.buttons["Chiudi"].tap()
        XCTAssertTrue(app.buttons["Dormi"].waitForExistence(timeout: 2))
    }

    @MainActor
    private func launch() -> XCUIApplication {
        let app = XCUIApplication()
        app.launchArguments = ["-AppleLanguages", "(it)", "-AppleLocale", "it_IT", "-lastCategory", "sounds", "-lastSoundID", "noise.white"]
        app.launchEnvironment["SBU_NOISE_FILE"] = "ui-\(UUID().uuidString).json"
        app.launchEnvironment["SBU_NOISE_BACKUP"] = "silent"
        app.launch()
        return app
    }

    /// The same exclusions as the player flow: contrast comes from the tokens. The system search
    /// field's placeholder is reported as clipped although it is drawn in full (checked on the
    /// screenshots): it is the system's control, not ours.
    @MainActor
    private func audit(_ app: XCUIApplication) throws {
        try app.performAccessibilityAudit(for: XCUIAccessibilityAuditType.all.subtracting([.contrast, .dynamicType])) { issue in
            if issue.auditType == .textClipped && issue.element?.elementType == .searchField { return true }
            XCTFail("\(issue.compactDescription): \(issue.element?.debugDescription ?? "no element")")
            return true
        }
    }
}
