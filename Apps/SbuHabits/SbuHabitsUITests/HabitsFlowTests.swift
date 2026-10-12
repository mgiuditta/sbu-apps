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
    private func habit(_ title: String, in app: XCUIApplication) -> XCUIElement {
        let cell = app.descendants(matching: .any).matching(identifier: title).firstMatch
        XCTAssertTrue(cell.waitForExistence(timeout: 5))
        return cell
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
        XCTAssertEqual(leggere.value as? String, "Da fare, 0 giorni")

        leggere.press(forDuration: 1)

        XCTAssertEqual(leggere.value as? String, "Fatta, 1 giorno")
        XCTAssertTrue(figure(in: app).contains("1"), figure(in: app))
    }

    @MainActor
    func testHoldingADoneHabitUndoesIt() {
        let app = launch()
        add("Leggere", in: app)
        let leggere = habit("Leggere", in: app)
        leggere.press(forDuration: 1)

        leggere.press(forDuration: 1)

        XCTAssertEqual(leggere.value as? String, "Da fare, 0 giorni")
    }

    @MainActor
    func testEachHoldFillsOneTimeAndTapUndoesOne() {
        let app = launch()
        add("Bere acqua", timesPerDay: 3, in: app)
        let acqua = habit("Bere acqua", in: app)
        XCTAssertEqual(acqua.value as? String, "0 di 3, 0 giorni")

        acqua.press(forDuration: 1)
        acqua.press(forDuration: 1)
        XCTAssertEqual(acqua.value as? String, "2 di 3, 0 giorni")

        acqua.press(forDuration: 1)
        XCTAssertEqual(acqua.value as? String, "3 di 3, 1 giorno")

        acqua.tap()
        app.buttons["Annulla ultima"].tap()
        XCTAssertEqual(acqua.value as? String, "2 di 3, 0 giorni")
    }

    @MainActor
    func testHabitsSurviveARelaunch() {
        var app = launch()
        add("Leggere", in: app)
        habit("Leggere", in: app).press(forDuration: 1)
        app.terminate()

        app = launch()

        XCTAssertEqual(habit("Leggere", in: app).value as? String, "Fatta, 1 giorno")
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
    func testToolScreenPassesTheAccessibilityAudit() throws {
        let app = launch()
        add("Bere acqua", timesPerDay: 3, in: app)
        add("Leggere", in: app)

        // Contrast is left out: text colors come from tokens with checked ratios, and the audit
        // misreads the iOS 26 glass bar and the ring's decorative track as text contrast.
        // The handler names the element in the failure, which the default message does not.
        try app.performAccessibilityAudit(for: XCUIAccessibilityAuditType.all.subtracting(.contrast)) { issue in
            XCTFail("\(issue.compactDescription): \(issue.element?.debugDescription ?? "no element")")
            return true
        }
    }
}
