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
            if issue.isRowCutByTheScreenEdge {
                return true
            }
            // Bar buttons and the round tabs keep their side: they show in the Large Content
            // Viewer instead of scaling.
            if issue.auditType == .dynamicType, ["Chiudi", "Cerca", "Annulla"].contains(issue.element?.label) {
                return true
            }
            // Personalizzata stops growing at AX2 on purpose: past it the word no longer fits the
            // row even alone on its line, and iOS would break it in half (#439).
            if issue.auditType == .dynamicType, issue.element?.label == "Personalizzata" {
                return true
            }
            XCTFail("\(issue.compactDescription): \(issue.element?.debugDescription ?? issue.detailedDescription)")
            return true
        }
    }

    /// The template rows, in screen order, by their title.
    @MainActor
    private func templateRow(_ title: String, in app: XCUIApplication) -> XCUIElement {
        let row = app.buttons.matching(NSPredicate(format: "label BEGINSWITH %@", title)).firstMatch
        app.reveal(row)
        return row
    }

    @MainActor
    func testTabsShowTheirTemplatesAndPassTheAccessibilityAudit() throws {
        let app = launch()
        app.openAddHabit()

        XCTAssertTrue(app.navigationBars["Aggiungi"].exists, app.debugDescription)
        XCTAssertTrue(app.buttons["Generale"].isSelected)
        XCTAssertFalse(app.buttons["Salute"].isSelected)
        app.reveal(app.staticTexts["Crea un'abitudine"])
        _ = templateRow("Leggere", in: app)
        app.reveal(app.buttons["Personalizzata"])
        // Kept with the results, to look at the rows at every text size the run uses.
        let shot = XCTAttachment(screenshot: app.screenshot())
        shot.lifetime = .keepAlways
        add(shot)
        try audit(app)

        app.tapButton(app.buttons["Salute"])

        XCTAssertTrue(app.buttons["Salute"].isSelected)
        XCTAssertFalse(app.buttons["Generale"].isSelected)
        app.reveal(app.staticTexts["Collegate a Salute: si segnano da sole quando arrivi all'obiettivo."])
        let walk = templateRow("Camminare", in: app)
        XCTAssertEqual(walk.value as? String, "Collegata a Salute", walk.debugDescription)
        try audit(app)

        app.tapButton(app.buttons["Da evitare"])
        app.reveal(app.staticTexts["Crea un'abitudine da evitare"])
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

        app.tapButton(app.addHabitButton)

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
        app.reveal(app.addHabitButton)
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
        XCTAssertTrue(app.staticTexts["Aggiungi la tua prima abitudine."].waitForExistence(timeout: 5))
    }
}
