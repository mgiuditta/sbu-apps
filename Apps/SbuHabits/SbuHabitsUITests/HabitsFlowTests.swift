import XCTest

/// Drives the tool screen like a person would: add, hold, undo, relaunch.
/// Runs in Italian on a throwaway file, so the simulator's own data and language never matter.
final class HabitsFlowTests: XCTestCase {
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
    private func add(_ title: String, timesPerDay: Int = 1, in app: XCUIApplication) {
        app.buttons["Aggiungi"].firstMatch.tap()
        let titleField = app.textFields["Titolo"]
        XCTAssertTrue(titleField.waitForExistence(timeout: 5))
        titleField.tap()
        titleField.typeText(title)
        for _ in 1..<timesPerDay {
            app.steppers.firstMatch.buttons.element(boundBy: 1).tap() // the "+" half
        }
        app.navigationBars.buttons["Aggiungi"].tap()
    }

    @MainActor
    private func addAvoided(_ title: String, limit: Int, in app: XCUIApplication) {
        app.buttons["Aggiungi"].firstMatch.tap()
        let titleField = app.textFields["Titolo"]
        XCTAssertTrue(titleField.waitForExistence(timeout: 5))
        app.buttons["Da evitare"].tap()
        titleField.tap()
        titleField.typeText(title)
        for _ in 0..<limit {
            app.steppers.firstMatch.buttons.element(boundBy: 1).tap() // the "+" half
        }
        app.navigationBars.buttons["Aggiungi"].tap()
    }

    @MainActor
    private func habit(_ title: String, in app: XCUIApplication) -> XCUIElement {
        let cell = app.descendants(matching: .any).matching(identifier: title).firstMatch
        XCTAssertTrue(cell.waitForExistence(timeout: 5))
        return cell
    }

    /// Waits for VoiceOver's value to settle: the screen updates a moment after the gesture.
    @MainActor
    private func expectValue(_ element: XCUIElement, _ value: String, file: StaticString = #filePath, line: UInt = #line) {
        let settled = XCTNSPredicateExpectation(predicate: NSPredicate(format: "value == %@", value), object: element)
        let result = XCTWaiter.wait(for: [settled], timeout: 5)
        XCTAssertEqual(result, .completed, "value is \(element.value ?? "nil")", file: file, line: line)
    }

    @MainActor
    private func figure(in app: XCUIApplication) -> String {
        app.descendants(matching: .any).matching(NSPredicate(format: "label BEGINSWITH 'Serie piena'")).firstMatch.label
    }

    @MainActor
    func testEmptyScreenInvitesToAdd() {
        let app = launch()

        XCTAssertTrue(app.staticTexts["Aggiungi la prima abitudine"].exists)
    }

    @MainActor
    func testBlankTitleCannotBeAdded() {
        let app = launch()
        app.buttons["Aggiungi"].firstMatch.tap()

        XCTAssertFalse(app.navigationBars.buttons["Aggiungi"].isEnabled)
    }

    @MainActor
    func testHoldingMarksAHabitDoneAndRaisesTheFullStreak() {
        let app = launch()
        add("Leggere", in: app)
        let leggere = habit("Leggere", in: app)
        expectValue(leggere, "Da fare, 0 giorni")

        leggere.press(forDuration: 1)

        expectValue(leggere, "Fatta, 1 giorno")
        XCTAssertTrue(figure(in: app).contains("1"), figure(in: app))
    }

    @MainActor
    func testHoldingADoneHabitUndoesIt() {
        let app = launch()
        add("Leggere", in: app)
        let leggere = habit("Leggere", in: app)
        leggere.press(forDuration: 1)

        leggere.press(forDuration: 1)

        expectValue(leggere, "Da fare, 0 giorni")
    }

    @MainActor
    func testEachHoldFillsOneTimeAndTapUndoesOne() {
        let app = launch()
        add("Bere acqua", timesPerDay: 3, in: app)
        let acqua = habit("Bere acqua", in: app)
        expectValue(acqua, "0 di 3, 0 giorni")

        acqua.press(forDuration: 1)
        acqua.press(forDuration: 1)
        expectValue(acqua, "2 di 3, 0 giorni")

        acqua.press(forDuration: 1)
        expectValue(acqua, "3 di 3, 1 giorno")

        acqua.tap()
        app.buttons["Annulla ultima"].tap()
        expectValue(acqua, "2 di 3, 0 giorni")
    }

    @MainActor
    func testHabitsSurviveARelaunch() {
        var app = launch()
        add("Leggere", in: app)
        habit("Leggere", in: app).press(forDuration: 1)
        app.terminate()

        app = launch()

        expectValue(habit("Leggere", in: app), "Fatta, 1 giorno")
    }

    @MainActor
    func testAHabitNotExpectedTodayStaysOutOfTheGrid() {
        let app = launch()
        add("Leggere", in: app)
        app.buttons["Aggiungi"].firstMatch.tap()
        app.textFields["Titolo"].tap()
        app.textFields["Titolo"].typeText("Palestra")
        app.buttons["Giorni della settimana"].tap()
        var italian = Calendar(identifier: .gregorian)
        italian.locale = Locale(identifier: "it_IT")
        let today = italian.standaloneWeekdaySymbols[italian.component(.weekday, from: .now) - 1]
        app.buttons[today].tap()
        app.navigationBars.buttons["Aggiungi"].tap()

        XCTAssertTrue(habit("Leggere", in: app).exists)
        XCTAssertFalse(app.descendants(matching: .any)["Palestra"].exists)
    }

    @MainActor
    func testAWeeklyHabitCountsDaysOfTheWeek() {
        let app = launch()
        app.buttons["Aggiungi"].firstMatch.tap()
        app.textFields["Titolo"].tap()
        app.textFields["Titolo"].typeText("Palestra")
        app.buttons["Volte a settimana"].tap()
        app.navigationBars.buttons["Aggiungi"].tap()
        let palestra = habit("Palestra", in: app)
        expectValue(palestra, "0 di 3, 0 settimane")

        palestra.press(forDuration: 1)

        expectValue(palestra, "1 di 3, 0 settimane")
    }

    @MainActor
    func testSkippingTodayCanBeTakenBack() {
        let app = launch()
        add("Leggere", in: app)
        let leggere = habit("Leggere", in: app)

        leggere.tap()
        app.buttons["Salta oggi"].tap()
        expectValue(leggere, "Saltata oggi, 0 giorni")

        leggere.tap()
        app.buttons["Non saltare oggi"].tap()
        expectValue(leggere, "Da fare, 0 giorni")
    }

    @MainActor
    func testEditingAndDeletingAHabit() {
        let app = launch()
        add("Leggere", in: app)

        habit("Leggere", in: app).tap()
        app.buttons["Modifica"].tap()
        let titleField = app.textFields["Titolo"]
        XCTAssertTrue(titleField.waitForExistence(timeout: 5))
        titleField.tap()
        XCTAssertTrue(app.keyboards.firstMatch.waitForExistence(timeout: 5))
        titleField.typeText(" ogni sera")
        app.navigationBars.buttons["Salva"].tap()
        let edited = habit("Leggere ogni sera", in: app)

        edited.tap()
        app.buttons["Modifica"].tap()
        // Elimina sits at the bottom of the form, past the symbols.
        app.collectionViews.firstMatch.swipeUp()
        app.collectionViews.firstMatch.swipeUp()
        app.buttons["Elimina"].firstMatch.tap()
        app.buttons["Elimina"].firstMatch.tap() // the confirmation
        XCTAssertTrue(app.staticTexts["Aggiungi la prima abitudine"].waitForExistence(timeout: 5))
    }

    @MainActor
    func testStatisticsShowAHabitsPage() {
        let app = launch()
        add("Leggere", in: app)
        habit("Leggere", in: app).press(forDuration: 1)

        app.buttons["Statistiche"].tap()
        app.buttons.matching(NSPredicate(format: "label BEGINSWITH 'Leggere'")).firstMatch.tap()

        XCTAssertTrue(app.staticTexts["Serie migliore: 1"].waitForExistence(timeout: 5))
    }

    @MainActor
    func testGivingInPastTheLimitIsMissed() {
        let app = launch()
        addAvoided("Caffè", limit: 1, in: app)
        let caffe = habit("Caffè", in: app)
        expectValue(caffe, "Da evitare, 0 su 1, 0 giorni")

        caffe.press(forDuration: 1)
        expectValue(caffe, "Da evitare, 1 su 1, 0 giorni")

        caffe.press(forDuration: 1)
        expectValue(caffe, "Da evitare, limite superato, 2 su 1, 0 giorni")

        caffe.tap()
        app.buttons["Annulla ultima"].tap()
        expectValue(caffe, "Da evitare, 1 su 1, 0 giorni")
    }

    @MainActor
    func testToolScreenPassesTheAccessibilityAudit() throws {
        let app = launch()
        add("Bere acqua", timesPerDay: 3, in: app)
        addAvoided("Caffè", limit: 2, in: app)
        // A third habit, alone on the last row: larger text pushes it past the screen (#97).
        add("Leggere", in: app)

        // Contrast is left out: text colors come from tokens with checked ratios, and the audit
        // misreads the iOS 26 glass bar and the ring's decorative track as text contrast.
        // The handler names the element in the failure, which the default message does not.
        try app.performAccessibilityAudit(for: XCUIAccessibilityAuditType.all.subtracting(.contrast)) { issue in
            XCTFail("\(issue.compactDescription): \(issue.element?.debugDescription ?? "no element")")
            return true
        }
    }

    @MainActor
    func testSettingsOfferExportAndImportAndPassTheAccessibilityAudit() throws {
        let app = launch()
        add("Leggere", in: app)

        app.buttons["Impostazioni"].tap()
        let export = app.buttons["Esporta"]
        XCTAssertTrue(export.waitForExistence(timeout: 5))
        XCTAssertTrue(export.isEnabled)
        XCTAssertTrue(app.buttons["Importa"].isEnabled)

        // Contrast is left out as on the tool screen. Dynamic Type too: in the settings sheet the
        // audit flags every text as partially unsupported, system ones included (the Fine button,
        // a plain section footer), so it says nothing about this screen.
        try app.performAccessibilityAudit(for: XCUIAccessibilityAuditType.all.subtracting([.contrast, .dynamicType])) { issue in
            XCTFail("\(issue.compactDescription): \(issue.element?.debugDescription ?? "no element")")
            return true
        }
    }
}
