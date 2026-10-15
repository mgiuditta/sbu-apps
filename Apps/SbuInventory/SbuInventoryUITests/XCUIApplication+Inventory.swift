import XCTest

extension XCUIApplication {
    /// The store a UI test starts from: empty, or the sample house at the top. Both live in memory,
    /// so the simulator's own data never matters.
    enum Store {
        case empty
        case sample
    }

    /// Launches in Italian (or `language`), on a store of its own, at the default text size unless `textSize` says otherwise.
    @MainActor
    static func inventory(_ store: Store, language: String = "it", textSize: String = "UICTContentSizeCategoryL") -> XCUIApplication {
        let app = XCUIApplication()
        let locale = language == "it" ? "it_IT" : "en_US"
        app.launchArguments += ["-AppleLanguages", "(\(language))", "-AppleLocale", locale]
        app.launchArguments += ["-UIPreferredContentSizeCategoryName", textSize]
        app.launchArguments += [store == .empty ? "-SBU_EMPTY_STORE" : "-SBU_SAMPLE_STORE", "YES"]
        app.launch()
        return app
    }

    /// Contrast comes from the design tokens, checked against WCAG by `Tools/sync_tokens.py`, and Dynamic Type
    /// is checked by hand at AX5, as in the other apps; every other issue fails the test.
    @MainActor
    func audit(file: StaticString = #filePath, line: UInt = #line) throws {
        try performAccessibilityAudit(for: XCUIAccessibilityAuditType.all.subtracting([.contrast, .dynamicType])) { issue in
            // SbuKit's uppercase captions are tracked, and the audit reads the last letter's tracking as a
            // clipped fraction of a point; on screen they are whole (as in Sbu Clean and Sbu Subscriptions).
            if issue.auditType == .textClipped, let label = issue.element?.label, label == label.uppercased() {
                return true
            }
            // A list row half under the screen's edge or a bar, as a scrolled list always has: the audit
            // reports it as clipped text without naming an element (as in Sbu Habits).
            if issue.auditType == .textClipped, issue.element == nil {
                return true
            }
            // Raised with no element while the keyboard is up: the predictive bar, not the app's text.
            if issue.auditType == .textClipped || issue.compactDescription.hasPrefix("Potentially inaccessible text"), issue.element == nil {
                return true
            }
            // The search field's own clear button is the system's, 20 points wide on every iPhone.
            if issue.auditType == .hitRegion, let label = issue.element?.label, ["Cancella testo", "Clear text"].contains(label) {
                return true
            }
            XCTFail("\(issue.compactDescription): \(issue.element?.debugDescription ?? issue.detailedDescription)", file: file, line: line)
            return true
        }
    }

    /// The element with this accessibility identifier, of any type.
    func element(_ identifier: String) -> XCUIElement {
        descendants(matching: .any).matching(identifier: identifier).firstMatch
    }
}

extension XCUIElement {
    /// Taps once the element is on screen and can take the tap, after a sheet has finished coming up.
    @MainActor
    func tapWhenReady(timeout: TimeInterval = 5, file: StaticString = #filePath, line: UInt = #line) {
        let ready = XCTNSPredicateExpectation(predicate: NSPredicate(format: "exists == true AND hittable == true"), object: self)
        XCTAssertEqual(XCTWaiter.wait(for: [ready], timeout: timeout), .completed, "\(self) never became tappable", file: file, line: line)
        tap()
    }

    /// Taps the button that backs out: Annulla in a sheet or an alert, the search's close button.
    @MainActor
    func tapCancel() {
        let labels = ["Annulla", "Cancel", "Chiudi", "Close", "chiudi", "close"]
        buttons.element(matching: NSPredicate(format: "label IN %@", labels)).firstMatch.tap()
    }
}

extension XCUIApplication {
    /// The first element whose label or value holds `text`, as a row of `LabeledContent` reads both together.
    func element(containing text: String) -> XCUIElement {
        descendants(matching: .any).matching(NSPredicate(format: "label CONTAINS %@ OR value CONTAINS %@", text, text)).firstMatch
    }

    /// Closes the search, so the screen shows its folders again.
    @MainActor
    func clearSearch() {
        tapCancel()
    }

    /// Adds an item from the + menu of the screen on top, with a name and, if not 1, a quantity typed in.
    @MainActor
    func addItem(_ name: String, quantity: Int? = nil) {
        element("add").tap()
        buttons["Oggetto"].tap()
        let field = textFields["itemName"]
        XCTAssertTrue(field.waitForExistence(timeout: 5))
        field.tap()
        field.typeText(name)
        if let quantity {
            let quantityField = textFields["quantityField"]
            quantityField.tap()
            quantityField.press(forDuration: 1.2)
            if menuItems["Seleziona tutto"].waitForExistence(timeout: 2) { menuItems["Seleziona tutto"].tap() }
            quantityField.typeText(XCUIKeyboardKey.delete.rawValue + "\(quantity)")
        }
        buttons["saveItem"].tap()
    }

    /// Creates a folder from the + menu of the screen on top.
    @MainActor
    func addFolder(_ name: String) {
        element("add").tap()
        buttons["Cartella"].tap()
        let field = alerts.textFields.firstMatch
        XCTAssertTrue(field.waitForExistence(timeout: 5))
        field.typeText(name)
        alerts.buttons["Crea"].tap()
    }
}
