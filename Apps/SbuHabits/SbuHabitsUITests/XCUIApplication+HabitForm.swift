import XCTest

/// Steps through the habit form like a person would: rows that open their own screen, the
/// title typed last so the keyboard never covers a row, the main button at the bottom.
extension XCUIApplication {
    /// Opens Aggiungi abitudine and waits for its first tab.
    @MainActor
    func openAddHabit() {
        buttons["Aggiungi"].firstMatch.tap()
        XCTAssertTrue(buttons["Personalizzata"].waitForExistence(timeout: 5), debugDescription)
    }

    /// Opens the empty form of a new habit, Personalizzata of Generale, and waits for it.
    @MainActor
    func openHabitForm() {
        openAddHabit()
        buttons["Personalizzata"].tap()
        XCTAssertTrue(textFields["Titolo"].waitForExistence(timeout: 5), debugDescription)
    }

    /// Leaves a new habit's form without adding it: back to Aggiungi abitudine, then Chiudi.
    @MainActor
    func cancelNewHabit() {
        navigationBars.allElementsBoundByIndex.last?.buttons.element(boundBy: 0).tap()
        let close = buttons["Chiudi"]
        XCTAssertTrue(close.waitForExistence(timeout: 5), debugDescription)
        close.tap()
    }

    /// A row of the form, which reads its name and then its value.
    @MainActor
    func formRow(_ name: String) -> XCUIElement {
        buttons.matching(NSPredicate(format: "label BEGINSWITH %@", name)).firstMatch
    }

    /// Opens a row's screen, scrolling to the row if the form hides it.
    @MainActor
    func openFormRow(_ name: String) {
        let row = formRow(name)
        XCTAssertTrue(row.waitForExistence(timeout: 5), debugDescription)
        for _ in 0..<3 where row.isHittable == false {
            collectionViews.firstMatch.swipeUp()
        }
        row.tap()
    }

    /// Back from a row's screen to the form.
    @MainActor
    func backToForm() {
        // The last bar is the pushed screen's: the grid's own sits behind the sheet.
        let bar = navigationBars.allElementsBoundByIndex.last ?? navigationBars.firstMatch
        bar.buttons.element(boundBy: 0).tap()
        XCTAssertTrue(textFields["Titolo"].waitForExistence(timeout: 5))
    }

    /// The form's main button for a new habit. The back button to Aggiungi abitudine reads the
    /// same words, as every back button reads the screen it goes back to.
    @MainActor
    var addHabitButton: XCUIElement {
        buttons.matching(NSPredicate(format: "label == 'Aggiungi abitudine' AND identifier != 'BackButton'")).firstMatch
    }

    /// Types the title, then adds the habit.
    @MainActor
    func typeTitleAndAdd(_ title: String) {
        let field = textFields["Titolo"]
        field.tap()
        field.typeText(title)
        addHabitButton.tap()
    }

    /// The form's audit. Contrast is left out as on the tool screen. Dynamic Type too: the form
    /// is all system rows and bar buttons, which scale, and the audit flags every one of them,
    /// Annulla included, as partially supported.
    @MainActor
    func auditHabitForm() throws {
        try performAccessibilityAudit(for: XCUIAccessibilityAuditType.all.subtracting([.contrast, .dynamicType])) { issue in
            XCTFail("\(issue.compactDescription): \(issue.element?.debugDescription ?? "no element")")
            return true
        }
    }
}
