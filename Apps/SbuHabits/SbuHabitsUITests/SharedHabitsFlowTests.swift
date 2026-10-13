import XCTest

/// The Abitudini condivise, on both sides, without iCloud: Condividi in the form, and a habit
/// someone shares, put on the grid by the launch environment.
final class SharedHabitsFlowTests: XCTestCase {
    private let file = "uitest-\(UUID().uuidString).json"
    private let sharedFile = "uitest-shared-\(UUID().uuidString).json"

    override func setUp() {
        continueAfterFailure = false
    }

    /// - Parameters:
    ///   - iCloud: Makes iCloud look signed in; nothing is ever shared.
    ///   - received: Starts with Correre, shared by someone else.
    @MainActor
    private func launch(iCloud: Bool = false, received: Bool = false) -> XCUIApplication {
        let app = XCUIApplication()
        app.launchArguments += ["-AppleLanguages", "(it)", "-AppleLocale", "it_IT"]
        app.launchEnvironment["SBU_HABITS_FILE"] = file
        app.launchEnvironment["SBU_HABITS_SHARED_FILE"] = sharedFile
        if iCloud {
            app.launchEnvironment["SBU_HABITS_ICLOUD"] = "available"
        }
        if received {
            app.launchEnvironment["SBU_HABITS_SHARED_DEMO"] = "1"
        }
        app.launch()
        return app
    }

    @MainActor
    private func cell(_ title: String, in app: XCUIApplication) -> XCUIElement {
        let cell = app.descendants(matching: .any).matching(identifier: title).firstMatch
        XCTAssertTrue(cell.waitForExistence(timeout: 5), app.debugDescription)
        return cell
    }

    /// Adds Leggere and opens its form.
    @MainActor
    private func editNewHabit(in app: XCUIApplication) -> XCUIElement {
        app.openHabitForm()
        app.typeTitleAndAdd("Leggere")
        cell("Leggere", in: app).tap()
        app.buttons["Modifica"].tap()
        XCTAssertTrue(app.textFields["Titolo"].waitForExistence(timeout: 5))
        let share = app.formRow("Condividi")
        // Condividi and its footer sit near the bottom, over Elimina.
        app.collectionViews.firstMatch.swipeUp()
        XCTAssertTrue(share.waitForExistence(timeout: 5), app.debugDescription)
        return share
    }

    @MainActor
    private func audit(_ app: XCUIApplication) throws {
        try app.performAccessibilityAudit(for: XCUIAccessibilityAuditType.all.subtracting([.contrast, .dynamicType])) { issue in
            XCTFail("\(issue.compactDescription): \(issue.element?.debugDescription ?? "no element")")
            return true
        }
    }

    @MainActor
    func testShareIsOffWithoutICloudAndSaysWhy() throws {
        let app = launch()
        let share = editNewHabit(in: app)

        XCTAssertFalse(share.isEnabled)
        XCTAssertTrue(app.staticTexts["Per condividere, accedi a iCloud nelle Impostazioni dell'iPhone."].exists, app.debugDescription)
        // Back at the top, as the form's other audits: scrolled, the fixed save button covers a row.
        app.collectionViews.firstMatch.swipeDown()
        try app.auditHabitForm()
    }

    @MainActor
    func testShareIsOnWithICloudAndSaysWhatTravels() {
        let app = launch(iCloud: true)
        let share = editNewHabit(in: app)

        XCTAssertTrue(share.isEnabled)
        XCTAssertTrue(app.staticTexts["Chi inviti vede l'abitudine e lo storico, non i promemoria né le note."].exists, app.debugDescription)
    }

    @MainActor
    func testANewHabitHasNoShareRow() {
        let app = launch(iCloud: true)
        app.openHabitForm()

        XCTAssertFalse(app.formRow("Condividi").exists)
        app.cancelNewHabit()
    }

    @MainActor
    func testASharedHabitIsReadOnlyInTheGrid() throws {
        let app = launch(received: true)
        let correre = cell("Correre", in: app)
        // Five days in a row up to yesterday, as the demo marks them.
        let value = "Da fare, 5 giorni, condivisa da un'altra persona"
        XCTAssertEqual(correre.value as? String, value)

        correre.press(forDuration: 1)

        XCTAssertTrue(app.staticTexts["Condivisa da un'altra persona: solo da vedere"].waitForExistence(timeout: 5))
        XCTAssertEqual(correre.value as? String, value)
        // Never in the user's Serie piena, nor in the user's habits: the grid still invites to add.
        XCTAssertTrue(app.staticTexts["Aggiungi la prima abitudine"].exists)
        XCTAssertFalse(app.buttons["Statistiche"].isEnabled)
        try audit(app)
    }

    @MainActor
    func testTheSharedScreenPicksTheOwnersIconAndShowsTheStatistics() throws {
        let app = launch(received: true)
        cell("Correre", in: app).tap()

        XCTAssertTrue(app.navigationBars["Abitudine condivisa"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.staticTexts["Questa abitudine è condivisa con te. Vedi i suoi progressi e le statistiche."].exists)
        XCTAssertTrue(app.buttons["Persona"].isSelected)
        let emoji = app.buttons["😎"]
        emoji.tap()
        XCTAssertTrue(emoji.isSelected)
        XCTAssertFalse(app.buttons["Persona"].isSelected)
        XCTAssertTrue(app.descendants(matching: .any).matching(NSPredicate(format: "label BEGINSWITH 'Completamento'")).firstMatch.exists)
        try audit(app)

        app.buttons["Fine"].tap()
        cell("Correre", in: app).tap()
        XCTAssertTrue(app.buttons["😎"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.buttons["😎"].isSelected)
    }

    @MainActor
    func testRemovingASharedHabitAsksFirst() {
        let app = launch(received: true)
        cell("Correre", in: app).tap()
        let remove = app.buttons["Rimuovi"].firstMatch
        XCTAssertTrue(remove.waitForExistence(timeout: 5))
        for _ in 0..<6 where remove.isHittable == false {
            app.scrollViews.firstMatch.swipeUp()
        }

        remove.tap()
        app.buttons["Rimuovi"].firstMatch.tap() // the confirmation

        XCTAssertTrue(app.staticTexts["Aggiungi la prima abitudine"].waitForExistence(timeout: 5))
        XCTAssertFalse(app.descendants(matching: .any).matching(identifier: "Correre").firstMatch.exists)
    }
}
