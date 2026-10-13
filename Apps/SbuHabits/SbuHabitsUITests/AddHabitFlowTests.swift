import XCTest

/// Drives Aggiungi abitudine like a person would: tabs, search, a Modello, the form filled in,
/// the habit on the grid. Runs in Italian on a throwaway file, as HabitsFlowTests does.
final class AddHabitFlowTests: XCTestCase {
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

    /// Contrast is left out as on the other screens.
    @MainActor
    private func audit(_ app: XCUIApplication) throws {
        try app.performAccessibilityAudit(for: XCUIAccessibilityAuditType.all.subtracting(.contrast)) { issue in
            // The system search field fits its placeholder; the audit reads the glass bar around
            // it as clipping it, as in the symbol picker.
            if issue.auditType == .textClipped, issue.element?.elementType == .searchField {
                return true
            }
            // On the iPhone 17 the audit reads Personalizzata's text frame (20 pt) as shorter than
            // its line, yet the row shows it whole (checked in the failure recording); the Pro Max
            // passes. The title wraps if it ever needs to.
            if issue.auditType == .textClipped, issue.element?.label == "Personalizzata" {
                return true
            }
            // Bar buttons and the round tabs keep their side: they show in the Large Content
            // Viewer instead of scaling.
            if issue.auditType == .dynamicType, ["Chiudi", "Cerca", "Annulla"].contains(issue.element?.label) {
                return true
            }
            XCTFail("\(issue.compactDescription): \(issue.element?.debugDescription ?? "no element")")
            return true
        }
    }

    /// The template rows, in screen order, by their title.
    @MainActor
    private func templateRow(_ title: String, in app: XCUIApplication) -> XCUIElement {
        let row = app.buttons.matching(NSPredicate(format: "label BEGINSWITH %@", title)).firstMatch
        XCTAssertTrue(row.waitForExistence(timeout: 5), app.debugDescription)
        return row
    }

    @MainActor
    func testTabsShowTheirTemplatesAndPassTheAccessibilityAudit() throws {
        let app = launch()
        app.openAddHabit()

        XCTAssertTrue(app.navigationBars["Aggiungi"].exists, app.debugDescription)
        XCTAssertTrue(app.buttons["Generale"].isSelected)
        XCTAssertFalse(app.buttons["Salute"].isSelected)
        XCTAssertTrue(app.staticTexts["Crea un'abitudine"].exists)
        _ = templateRow("Leggere", in: app)
        try audit(app)

        app.buttons["Salute"].tap()

        XCTAssertTrue(app.buttons["Salute"].isSelected)
        XCTAssertFalse(app.buttons["Generale"].isSelected)
        XCTAssertTrue(app.staticTexts["Collegate a Salute: si segnano da sole quando arrivi all'obiettivo."].exists)
        let walk = templateRow("Camminare", in: app)
        XCTAssertEqual(walk.value as? String, "Collegata a Salute", walk.debugDescription)
        try audit(app)

        app.buttons["Da evitare"].tap()
        XCTAssertTrue(app.staticTexts["Crea un'abitudine da evitare"].waitForExistence(timeout: 5))
        _ = templateRow("Niente dolci", in: app)
        app.buttons["Chiudi"].tap()
        XCTAssertTrue(app.buttons["Aggiungi"].waitForExistence(timeout: 5))
    }

    @MainActor
    func testATemplateFoundBySearchIsAddedFromItsFilledForm() throws {
        let app = launch()
        app.openAddHabit()
        app.buttons["Cerca"].tap()
        let search = app.searchFields["Cerca un modello"]
        XCTAssertTrue(search.waitForExistence(timeout: 5))

        // Across the tabs and in English too, accents and case aside.
        // Return puts the keyboard away, whose suggestions the audit would read.
        search.typeText("SWEETS\n")
        let sweets = templateRow("Niente dolci", in: app)
        XCTAssertTrue(app.staticTexts["Da evitare"].exists, app.debugDescription)
        XCTAssertFalse(app.buttons["Personalizzata"].exists)
        try audit(app)

        sweets.tap()

        let title = app.textFields["Titolo"]
        XCTAssertTrue(title.waitForExistence(timeout: 5))
        XCTAssertEqual(title.value as? String, "Niente dolci")
        let tipo = app.formRow("Tipo")
        XCTAssertTrue("\(tipo.label) \(tipo.value as? String ?? "")".contains("Da evitare"), tipo.debugDescription)
        let limit = app.formRow("Limite")
        XCTAssertTrue("\(limit.label) \(limit.value as? String ?? "")".contains("Mai"), limit.debugDescription)
        try app.auditHabitForm()

        app.addHabitButton.tap()

        let habit = app.descendants(matching: .any).matching(identifier: "Niente dolci").firstMatch
        XCTAssertTrue(habit.waitForExistence(timeout: 5))
        XCTAssertTrue((habit.value as? String ?? "").hasPrefix("Da evitare"), habit.debugDescription)
    }

    @MainActor
    func testSameTitledResultsReadApartAndTheFormsBackButtonIsNotItsMainButton() {
        let app = launch()
        app.openAddHabit()
        app.buttons["Cerca"].tap()
        let search = app.searchFields["Cerca un modello"]
        XCTAssertTrue(search.waitForExistence(timeout: 5))

        search.typeText("leggere\n")

        let rows = app.buttons.matching(NSPredicate(format: "label BEGINSWITH 'Leggere'"))
        XCTAssertTrue(rows.firstMatch.waitForExistence(timeout: 5), app.debugDescription)
        let labels = rows.allElementsBoundByIndex.map(\.label)
        XCTAssertEqual(labels.count, 2, app.debugDescription)
        XCTAssertEqual(Set(labels).count, 2, "\(labels)")
        XCTAssertTrue(labels.contains { $0.contains("A tempo") }, "\(labels)")

        rows.firstMatch.tap()

        XCTAssertTrue(app.textFields["Titolo"].waitForExistence(timeout: 5))
        let back = app.navigationBars.allElementsBoundByIndex.last?.buttons.element(boundBy: 0)
        XCTAssertEqual(back?.label, "Aggiungi", back?.debugDescription ?? app.debugDescription)
        XCTAssertTrue(app.addHabitButton.exists)
    }

    @MainActor
    func testASearchWithNoMatchSaysSo() {
        let app = launch()
        app.openAddHabit()
        app.buttons["Cerca"].tap()
        let search = app.searchFields["Cerca un modello"]
        XCTAssertTrue(search.waitForExistence(timeout: 5))

        search.typeText("xyzxyz")

        XCTAssertTrue(app.staticTexts.matching(NSPredicate(format: "label CONTAINS 'xyzxyz'")).firstMatch.waitForExistence(timeout: 5), app.debugDescription)
        XCTAssertFalse(app.buttons["Personalizzata"].exists)
    }

    @MainActor
    func testPersonalizzataStartsTheFormAsItsTabSays() {
        let app = launch()
        app.openAddHabit()
        app.buttons["Da evitare"].tap()
        app.buttons["Personalizzata"].tap()

        XCTAssertTrue(app.formRow("Limite").waitForExistence(timeout: 5), app.debugDescription)
        let title = app.textFields["Titolo"]
        // Blank, so automatic: an empty field reads its prompt.
        XCTAssertTrue(["", "Automatico"].contains(title.value as? String ?? ""), title.debugDescription)

        app.cancelNewHabit()
        XCTAssertTrue(app.staticTexts["Aggiungi la prima abitudine"].waitForExistence(timeout: 5))
    }
}
