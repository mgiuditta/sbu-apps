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

    /// Scrolls the screen's list until `element` is on screen: down first, then back up. At the
    /// accessibility text sizes a row can be several screens away, and the list only makes the
    /// rows near the screen.
    @MainActor
    func reveal(_ element: XCUIElement) {
        let list = collectionViews.firstMatch
        _ = element.waitForExistence(timeout: 2)
        // The list does not scroll under the keyboard: Return closes it first.
        let returnKey = buttons["Return"]
        if element.isHittable == false, keyboards.firstMatch.exists, returnKey.exists {
            returnKey.tap()
        }
        for _ in 0..<10 where isOnScreen(element) == false {
            list.swipeUp()
        }
        for _ in 0..<10 where isOnScreen(element) == false {
            list.swipeDown()
        }
        XCTAssertTrue(isOnScreen(element), debugDescription)
    }

    /// Hittable, or for text a footer does not make hittable, its centre inside the window.
    @MainActor
    private func isOnScreen(_ element: XCUIElement) -> Bool {
        if element.isHittable {
            return true
        }
        guard element.exists, element.elementType == .staticText else { return false }
        let frame = element.frame
        return windows.firstMatch.frame.contains(CGPoint(x: frame.midX, y: frame.midY))
    }

    /// Taps a button once it is on screen.
    @MainActor
    func tapButton(_ button: XCUIElement) {
        reveal(button)
        button.tap()
    }

    /// Flips a named switch once it is on screen.
    @MainActor
    func toggleSwitch(_ name: String) {
        let toggle = switches[name]
        reveal(toggle)
        toggle.switches.firstMatch.tap()
    }

    /// The "+" half of the screen's stepper.
    @MainActor
    func tapStepperPlus() {
        let plus = steppers.firstMatch.buttons.element(boundBy: 1)
        reveal(plus)
        plus.tap()
    }

    /// Opens a row's screen, scrolling to the row if the form hides it.
    @MainActor
    func openFormRow(_ name: String) {
        let row = formRow(name)
        reveal(row)
        // A row under the fixed button still reads as hittable, and the tap would add the habit.
        let fixedButton = buttons.matching(NSPredicate(format: "label IN %@", ["Aggiungi abitudine", "Salva abitudine"])).firstMatch
        let list = collectionViews.firstMatch
        for _ in 0..<5 where fixedButton.exists && row.frame.maxY > fixedButton.frame.minY {
            let start = list.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.6))
            start.press(forDuration: 0.05, thenDragTo: start.withOffset(CGVector(dx: 0, dy: -150)))
        }
        row.tap()
    }

    /// Back from a row's screen to the form.
    @MainActor
    func backToForm() {
        // The last bar is the pushed screen's: the grid's own sits behind the sheet.
        let bar = navigationBars.allElementsBoundByIndex.last ?? navigationBars.firstMatch
        bar.buttons.element(boundBy: 0).tap()
        let form = navigationBars.matching(NSPredicate(format: "identifier IN %@", ["Nuova abitudine", "Modifica abitudine"])).firstMatch
        XCTAssertTrue(form.waitForExistence(timeout: 5), debugDescription)
    }

    /// The form's main button for a new habit. The back button reads "Aggiungi", the title of
    /// the sheet it goes back to, so VoiceOver tells the two apart.
    @MainActor
    var addHabitButton: XCUIElement {
        buttons["Aggiungi abitudine"].firstMatch
    }

    /// Types the title, then adds the habit.
    @MainActor
    func typeTitleAndAdd(_ title: String) {
        let field = textFields["Titolo"]
        reveal(field)
        field.tap()
        field.typeText(title + "\n") // Return closes the keyboard, which would cover the button
        reveal(addHabitButton)
        addHabitButton.tap()
    }

    /// Taps a destructive button, then the same-named button of its confirmation. On an iPhone
    /// the confirmation can be a popover over the button, with the button still reachable, so
    /// the confirming one is told apart by where it is.
    @MainActor
    func tapAndConfirm(_ button: XCUIElement, question: String) throws {
        reveal(button)
        let source = button.frame
        let label = button.label
        button.tap()
        XCTAssertTrue(staticTexts[question].waitForExistence(timeout: 5), debugDescription)
        let confirm = buttons.matching(identifier: label).allElementsBoundByIndex.first { candidate in
            candidate.frame != source && candidate.isHittable
        }
        try XCTUnwrap(confirm, debugDescription).tap()
    }

    /// The form's audit. Contrast is left out as on the tool screen. Dynamic Type too: the form
    /// is all system rows and bar buttons, which scale, and the audit flags every one of them,
    /// Annulla included, as partially supported.
    @MainActor
    func auditHabitForm() throws {
        try performAccessibilityAudit(for: XCUIAccessibilityAuditType.all.subtracting([.contrast, .dynamicType])) { issue in
            if issue.isRowCutByTheScreenEdge {
                return true
            }
            // Growing the text past the first accessibility size moves the fixed button into the
            // list, and the audit reads a row's name as cut during that change. Run at XXXL, AX1,
            // AX3 and AX5, this test passes and every name shows whole (#439).
            if issue.auditType == .textClipped, issue.element?.elementType == .staticText,
               ["Tipo", "Obiettivo", "Giorni", "Notifiche", "Salute", "Condividi"].contains(issue.element?.label) {
                return true
            }
            XCTFail("\(issue.compactDescription): \(issue.element?.debugDescription ?? issue.detailedDescription)")
            return true
        }
    }
}
