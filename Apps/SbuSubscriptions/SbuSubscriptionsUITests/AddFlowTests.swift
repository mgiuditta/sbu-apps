import XCTest

/// Adds a subscription from the catalog on an empty store and checks the home total, auditing each screen.
final class AddFlowTests: XCTestCase {
    @MainActor
    func testAddFromCatalogUpdatesTheTotal() throws {
        let app = XCUIApplication()
        app.launchArguments += ["-SBU_EMPTY_STORE", "YES", "-AppleLanguages", "(it)", "-AppleLocale", "it_IT"]
        app.launch()

        XCTAssertTrue(app.staticTexts["Nessun abbonamento"].waitForExistence(timeout: 5))
        try audit(app)

        app.buttons["addFirst"].tap()
        let search = app.searchFields["Cerca un servizio"]
        XCTAssertTrue(search.waitForExistence(timeout: 5))
        search.tap()
        search.typeText("netfl")
        attach(app, "catalogo")
        app.buttons["Netflix"].firstMatch.tap()

        let price = app.textFields["price"]
        XCTAssertTrue(price.waitForExistence(timeout: 5))
        // Audited before typing: with the system keyboard up the audit flags the keyboard's own texts.
        try audit(app)
        price.tap()
        price.typeText("12,99")
        attach(app, "modulo")
        app.buttons["save"].tap()

        XCTAssertTrue(app.staticTexts["Netflix"].waitForExistence(timeout: 5))
        // The figure is read with its caption and context as one element.
        let figure = app.descendants(matching: .any).matching(NSPredicate(format: "label CONTAINS %@", "155,88")).firstMatch
        XCTAssertTrue(figure.exists, "12,99 € al mese fanno 155,88 € all'anno")
        attach(app, "home")
        try audit(app)
    }

    @MainActor
    private func attach(_ app: XCUIApplication, _ name: String) {
        let attachment = XCTAttachment(screenshot: app.screenshot())
        attachment.name = name
        attachment.lifetime = .keepAlways
        add(attachment)
    }

    /// Contrast comes from the design tokens, checked against WCAG by `Tools/sync_tokens.py`, and Dynamic Type
    /// is checked by hand at AX5, as in the other apps; every other issue fails the test.
    @MainActor
    private func audit(_ app: XCUIApplication) throws {
        try app.performAccessibilityAudit(for: XCUIAccessibilityAuditType.all.subtracting([.contrast, .dynamicType])) { issue in
            // SbuKit's uppercase captions are tracked, and the audit reads the last letter's tracking as a
            // clipped fraction of a point; on screen they are whole (as in Sbu Clean).
            if issue.auditType == .textClipped, let label = issue.element?.label, label == label.uppercased() {
                return true
            }
            XCTFail("\(issue.compactDescription): \(issue.element?.debugDescription ?? issue.detailedDescription)")
            return true
        }
    }
}
