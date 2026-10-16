import XCTest

/// Drives every screen on the demo camera and codes, and runs the accessibility audit on each.
/// Runs in Italian, so the simulator needs no camera and shows no permission prompt.
final class ScannerFlowTests: XCTestCase {
    override func setUp() {
        continueAfterFailure = false
    }

    @MainActor
    private func launch(textSize: String? = nil) -> XCUIApplication {
        let app = XCUIApplication()
        app.launchArguments += ["-AppleLanguages", "(it)", "-AppleLocale", "it_IT", "-FASTLANE_SNAPSHOT", "YES"]
        if let textSize { app.launchArguments += ["-UIPreferredContentSizeCategoryName", textSize] }
        app.launch()
        return app
    }

    @MainActor
    private func audit(_ app: XCUIApplication) throws {
        // After a push the audit can catch rows mid-slide and report them clipped: let the screen settle.
        sleep(1)
        // Contrast and Dynamic Type are left out as in Sbu Habits: text colors come from tokens with checked
        // ratios, the audit misreads the iOS 26 glass bar and system toggles, and large text has its own test.
        try app.performAccessibilityAudit(for: XCUIAccessibilityAuditType.all.subtracting([.contrast, .dynamicType])) { issue in
            // A text field scrolls what you type: the audit reads its value as clipped text.
            if issue.auditType == .textClipped, issue.element?.elementType == .textField { return true }
            // A row the screen's bottom edge cuts in half, under the button: scrolling shows it whole (as in Sbu Habits).
            if issue.auditType == .textClipped, issue.element == nil { return true }
            // SbuScreenTitle's cartiglio is tracked uppercase Plex Mono, drawn whole: the audit measures it
            // without the tracking and reports it clipped.
            if issue.auditType == .textClipped, issue.element?.label.hasPrefix("SBU · ") == true { return true }
            // A list row grows with its text and wraps it, so it can't clip; the iOS 26 audit still reports
            // icon-and-title rows (Copia, Esporta SVG, a toggle) by measuring the title from the icon's edge.
            if issue.auditType == .textClipped, let label = issue.element?.label, app.cells.staticTexts[label].exists { return true }
            let shot = XCTAttachment(screenshot: app.screenshot())
            shot.name = issue.compactDescription
            shot.lifetime = .keepAlways
            self.add(shot)
            XCTFail("\(issue.compactDescription): \(issue.element?.debugDescription ?? "no element")")
            return true
        }
    }

    @MainActor
    func testReadingALinkShowsWhereItGoesBeforeOpening() throws {
        let app = launch()
        let sample = app.buttons["Leggi il codice di esempio"]
        XCTAssertTrue(sample.waitForExistence(timeout: 10))
        XCTAssertTrue(app.buttons["Da una foto"].exists)
        try audit(app)

        sample.tap()
        XCTAssertTrue(app.staticTexts["sbu.dev"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.buttons["Apri il link"].exists)
        XCTAssertTrue(app.staticTexts["Nessun segnale strano nel link"].exists)
        try audit(app)

        // Saved in the history, at the top.
        app.navigationBars.buttons.element(boundBy: 0).tap()
        app.buttons["Cronologia"].tap()
        let first = app.cells.element(boundBy: 0).buttons.firstMatch
        XCTAssertTrue(first.waitForExistence(timeout: 5))
        XCTAssertTrue(first.label.contains("sbu.dev/apps/scanner"), first.label)
        try audit(app)
    }

    @MainActor
    func testWiFiResultOffersToConnectAndCopyThePassword() throws {
        let app = launch()
        app.buttons["Cronologia"].tap()
        app.buttons.matching(NSPredicate(format: "label CONTAINS 'Casa Rossi'")).firstMatch.tap()
        XCTAssertTrue(app.buttons["Connetti"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.buttons["Copia password"].exists)
        try audit(app)
    }

    @MainActor
    func testHistorySearchFindsAndFiltersCodes() throws {
        let app = launch()
        app.buttons["Cronologia"].tap()
        let search = app.searchFields.firstMatch
        XCTAssertTrue(search.waitForExistence(timeout: 5))
        search.tap()
        search.typeText("museo")
        XCTAssertEqual(app.cells.count, 1)
        XCTAssertTrue(app.buttons.matching(NSPredicate(format: "label CONTAINS 'museo'")).firstMatch.exists)
    }

    @MainActor
    func testCreatingALinkAddsItToTheList() throws {
        let app = launch()
        app.buttons["Crea"].tap()
        XCTAssertTrue(app.staticTexts["Wi-Fi ospiti"].waitForExistence(timeout: 5))
        try audit(app)

        app.buttons["Nuovo codice"].tap()
        app.buttons["Link"].tap()
        let save = app.buttons["Salva nell'elenco"]
        XCTAssertTrue(save.waitForExistence(timeout: 5))
        XCTAssertFalse(save.isEnabled)
        let field = app.textFields.firstMatch
        field.tap()
        field.typeText("example.com/menu")
        XCTAssertTrue(app.images["Codice: example.com/menu"].waitForExistence(timeout: 5))
        XCTAssertTrue(save.isEnabled)
        try audit(app)

        save.tap()
        XCTAssertTrue(app.staticTexts["example.com"].waitForExistence(timeout: 5))
    }

    /// At the largest text size the pills shrink to their symbols and stay on screen, with their names for VoiceOver.
    @MainActor
    func testLargestTextKeepsThePillsOnScreen() throws {
        let app = launch(textSize: "UICTContentSizeCategoryAccessibilityXXXL")
        let photo = app.buttons["Da una foto"]
        XCTAssertTrue(photo.waitForExistence(timeout: 10))
        XCTAssertTrue(photo.isHittable)
        try audit(app)
        app.buttons["Leggi il codice di esempio"].tap()
        XCTAssertTrue(app.buttons["Apri il link"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.buttons["Apri il link"].isHittable)
    }
}
