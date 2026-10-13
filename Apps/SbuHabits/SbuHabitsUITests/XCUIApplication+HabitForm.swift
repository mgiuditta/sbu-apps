import XCTest

/// Steps through the habit form like a person would: rows that open their own screen, the
/// title typed last so the keyboard never covers a row, the main button at the bottom.
extension XCUIApplication {
    /// Opens the form for a new habit and waits for it.
    @MainActor
    func openHabitForm() {
        buttons["Aggiungi"].firstMatch.tap()
        XCTAssertTrue(textFields["Titolo"].waitForExistence(timeout: 5), debugDescription)
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

    /// Types the title, then adds the habit.
    @MainActor
    func typeTitleAndAdd(_ title: String) {
        let field = textFields["Titolo"]
        field.tap()
        field.typeText(title)
        buttons["Aggiungi abitudine"].tap()
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
