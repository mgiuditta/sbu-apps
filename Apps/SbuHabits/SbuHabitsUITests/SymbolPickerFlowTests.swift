import XCTest

/// Opens the symbol picker from the form, searches and picks, in Italian on a throwaway file.
final class SymbolPickerFlowTests: XCTestCase {
    private let file = "uitest-\(UUID().uuidString).json"

    override func setUp() {
        continueAfterFailure = false
    }

    @MainActor
    private func launch() -> XCUIApplication {
        let app = XCUIApplication()
        app.launchArguments += ["-AppleLanguages", "(it)", "-AppleLocale", "it_IT"]
        app.launchEnvironment["SBU_HABITS_FILE"] = file
        app.launch()
        return app
    }

    @MainActor
    private func symbolRow(in app: XCUIApplication) -> XCUIElement {
        app.buttons.matching(NSPredicate(format: "label BEGINSWITH 'Simbolo'")).firstMatch
    }

    @MainActor
    func testSearchingAndPickingASymbol() throws {
        let app = launch()
        app.buttons["Aggiungi"].firstMatch.tap()
        let row = symbolRow(in: app)
        XCTAssertTrue(row.waitForExistence(timeout: 5))
        XCTAssertTrue("\(row.label) \(row.value as? String ?? "")".contains("Acqua"), row.debugDescription)

        row.tap()
        let search = app.searchFields["Cerca un simbolo"]
        XCTAssertTrue(search.waitForExistence(timeout: 5))
        // The first group is on screen, the chosen symbol marked as such.
        XCTAssertTrue(app.staticTexts["Salute e corpo"].exists)
        XCTAssertTrue(app.buttons["Acqua"].isSelected)
        // At full height, as people browse hundreds of symbols: at the medium detent the audit
        // reads the dimmed form behind the sheet as inaccessible text.
        app.navigationBars["Simbolo"].swipeUp()
        XCTAssertTrue(search.waitForExistence(timeout: 5))

        // Contrast is left out as on the other screens.
        try app.performAccessibilityAudit(for: XCUIAccessibilityAuditType.all.subtracting(.contrast)) { issue in
            // The system search field fits its placeholder (see the screenshots); the audit reads
            // the glass bar around it as clipping it.
            if issue.auditType == .textClipped, issue.element?.elementType == .searchField {
                return true
            }
            // A bar button: the system shows it in the Large Content Viewer instead of scaling it.
            if issue.auditType == .dynamicType, issue.element?.label == "Annulla" {
                return true
            }
            XCTFail("\(issue.compactDescription): \(issue.element?.debugDescription ?? "no element")")
            return true
        }

        search.tap()
        search.typeText("running")
        XCTAssertTrue(app.buttons["Corsa"].waitForExistence(timeout: 5))
        XCTAssertFalse(app.buttons["Acqua"].exists)
        app.buttons["Corsa"].tap()

        XCTAssertTrue(search.waitForNonExistence(timeout: 5))
        XCTAssertTrue("\(row.label) \(row.value as? String ?? "")".contains("Corsa"), row.debugDescription)

        // The habit keeps it: it shows again when you edit it.
        app.textFields["Titolo"].tap()
        app.textFields["Titolo"].typeText("Correre")
        app.navigationBars.buttons["Aggiungi"].tap()
        let habit = app.descendants(matching: .any).matching(identifier: "Correre").firstMatch
        XCTAssertTrue(habit.waitForExistence(timeout: 5))
        habit.tap()
        app.buttons["Modifica"].tap()
        XCTAssertTrue(row.waitForExistence(timeout: 5))
        XCTAssertTrue("\(row.label) \(row.value as? String ?? "")".contains("Corsa"), row.debugDescription)
    }

    @MainActor
    func testASearchWithNoMatchSaysSo() {
        let app = launch()
        app.buttons["Aggiungi"].firstMatch.tap()
        symbolRow(in: app).tap()
        let search = app.searchFields["Cerca un simbolo"]
        XCTAssertTrue(search.waitForExistence(timeout: 5))

        search.tap()
        search.typeText("xyzxyz")

        XCTAssertFalse(app.buttons["Acqua"].exists)
        XCTAssertTrue(app.staticTexts.matching(NSPredicate(format: "label CONTAINS 'xyzxyz'")).firstMatch.waitForExistence(timeout: 5))
    }
}
