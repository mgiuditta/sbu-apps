import XCTest

/// Drives the tool screen like a person would: add, hold, undo, relaunch.
/// Runs in Italian on a throwaway file, so the simulator's own data and language never matter.
final class HabitsFlowTests: XCTestCase {
    private let file = "uitest-\(UUID().uuidString).json"

    override func setUp() {
        continueAfterFailure = false
    }

    /// - Parameters:
    ///   - iCloud: Makes iCloud look signed in; the app still never syncs a test file.
    ///   - defaultTextSize: Runs at the default text size whatever the iPhone's, for what only
    ///     exists there, such as the grid's pages.
    @MainActor
    private func launch(iCloud: Bool = false, defaultTextSize: Bool = false) -> XCUIApplication {
        let app = XCUIApplication()
        app.launchArguments += ["-AppleLanguages", "(it)", "-AppleLocale", "it_IT"]
        if defaultTextSize {
            app.launchArguments += ["-UIPreferredContentSizeCategoryName", "UICTContentSizeCategoryL"]
        }
        app.launchEnvironment["SBU_HABITS_FILE"] = file
        if iCloud {
            app.launchEnvironment["SBU_HABITS_ICLOUD"] = "available"
        }
        app.launch()
        return app
    }

    @MainActor
    private func add(_ title: String, timesPerDay: Int = 1, in app: XCUIApplication) {
        app.openHabitForm()
        if timesPerDay > 1 {
            app.openFormRow("Obiettivo")
            for _ in 1..<timesPerDay {
                app.tapStepperPlus()
            }
            app.backToForm()
        }
        app.typeTitleAndAdd(title)
    }

    @MainActor
    private func addAvoided(_ title: String, limit: Int, in app: XCUIApplication) {
        app.openHabitForm()
        app.openFormRow("Tipo")
        app.buttons["Da evitare"].tap()
        app.backToForm()
        app.openFormRow("Limite")
        for _ in 0..<limit {
            app.tapStepperPlus()
        }
        app.backToForm()
        app.typeTitleAndAdd(title)
    }

    /// Adds a habit with the schedule picked on the Giorni screen.
    @MainActor
    private func add(_ title: String, schedule: String, in app: XCUIApplication) {
        app.openHabitForm()
        app.openFormRow("Giorni")
        app.buttons[schedule].tap()
        app.backToForm()
        app.typeTitleAndAdd(title)
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
    func testABlankTitleAddsTheAutomaticOne() throws {
        let app = launch()
        app.openHabitForm()
        XCTAssertEqual(app.textFields["Titolo"].placeholderValue, "Automatico")
        // The preview reads the title the habit will get: the default symbol's name.
        XCTAssertTrue(app.staticTexts["Acqua"].exists, app.debugDescription)
        try app.auditHabitForm()
        // Kept with the results, to look at the form's end at every text size the run uses.
        app.reveal(app.addHabitButton)
        let shot = XCTAttachment(screenshot: app.screenshot())
        shot.lifetime = .keepAlways
        add(shot)

        app.openFormRow("Notifiche")
        XCTAssertTrue(app.buttons["Nessun promemoria"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.staticTexts["Acqua"].exists, app.debugDescription)
        try app.auditHabitForm()
        app.backToForm()
        app.tapButton(app.addHabitButton)

        expectValue(habit("Acqua", in: app), "Da fare, 0 giorni")
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
        app.buttons["Annulla l'ultimo segno"].tap()
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
        app.openHabitForm()
        app.openFormRow("Giorni")
        app.buttons["Giorni della settimana"].tap()
        var italian = Calendar(identifier: .gregorian)
        italian.locale = Locale(identifier: "it_IT")
        let today = italian.standaloneWeekdaySymbols[italian.component(.weekday, from: .now) - 1]
        app.buttons[today].tap()
        app.backToForm()
        app.typeTitleAndAdd("Palestra")

        XCTAssertTrue(habit("Leggere", in: app).exists)
        XCTAssertFalse(app.descendants(matching: .any)["Palestra"].exists)
    }

    @MainActor
    func testAWeeklyHabitCountsDaysOfTheWeek() {
        let app = launch()
        add("Palestra", schedule: "Volte a settimana", in: app)
        let palestra = habit("Palestra", in: app)
        expectValue(palestra, "0 di 3, 0 settimane")

        palestra.press(forDuration: 1)

        expectValue(palestra, "1 di 3, 0 settimane")
    }

    @MainActor
    func testAMonthlyHabitCountsDaysOfTheMonth() {
        let app = launch()
        add("Biblioteca", schedule: "Volte al mese", in: app)
        let biblioteca = habit("Biblioteca", in: app)
        expectValue(biblioteca, "0 di 10, 0 mesi")

        biblioteca.press(forDuration: 1)

        expectValue(biblioteca, "1 di 10, 0 mesi")
    }

    @MainActor
    func testAnAttivitaDiUnGiornoForTodayIsInTheGrid() throws {
        let app = launch()
        app.openHabitForm()
        app.openFormRow("Giorni")
        app.tapButton(app.buttons["Un giorno solo"])

        app.reveal(app.staticTexts["Compare nella griglia solo quel giorno."])
        app.reveal(app.datePickers.firstMatch)
        try app.auditHabitForm()
        app.backToForm()
        app.typeTitleAndAdd("Dentista")

        expectValue(habit("Dentista", in: app), "Da fare, 0 giorni")
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
        app.buttons["Annulla il salto di oggi"].tap()
        expectValue(leggere, "Da fare, 0 giorni")
    }

    /// The text field of the Nota del giorno: a field on more lines may surface as a text view.
    @MainActor
    private func noteField(in app: XCUIApplication) -> XCUIElement {
        let field = app.descendants(matching: .any).matching(NSPredicate(
            format: "label == 'Nota' AND (elementType == %d OR elementType == %d)",
            XCUIElement.ElementType.textField.rawValue,
            XCUIElement.ElementType.textView.rawValue
        )).firstMatch
        XCTAssertTrue(field.waitForExistence(timeout: 5))
        return field
    }

    @MainActor
    func testANoteOfTheDayIsWrittenShownAndEdited() throws {
        let app = launch()
        add("Leggere", in: app)
        let leggere = habit("Leggere", in: app)

        leggere.tap()
        app.buttons["Scrivi nota"].tap()
        let field = noteField(in: app)
        XCTAssertTrue(app.keyboards.firstMatch.waitForExistence(timeout: 5))
        field.typeText("Venti pagine")
        expectValue(app.staticTexts["Caratteri"], "12 di 500")
        try app.performAccessibilityAudit(for: XCUIAccessibilityAuditType.all.subtracting([.contrast, .dynamicType])) { issue in
            XCTFail("\(issue.compactDescription): \(issue.element?.debugDescription ?? issue.detailedDescription)")
            return true
        }
        app.buttons["Fine"].tap()
        expectValue(leggere, "Da fare, 0 giorni, con nota")

        leggere.tap()
        app.buttons["Modifica nota"].tap()
        let reopened = noteField(in: app)
        XCTAssertEqual(reopened.value as? String, "Venti pagine")
        reopened.tap()
        reopened.typeText(" e un caffè")
        app.buttons["Fine"].tap()
        expectValue(leggere, "Da fare, 0 giorni, con nota")

        app.buttons["Statistiche"].tap()
        app.buttons["statistics-Leggere"].tap()
        let note = app.buttons.matching(NSPredicate(format: "label CONTAINS 'Venti pagine e un caffè'")).firstMatch
        XCTAssertTrue(note.waitForExistence(timeout: 5))
        try app.performAccessibilityAudit(for: XCUIAccessibilityAuditType.all.subtracting([.contrast, .dynamicType])) { issue in
            XCTFail("\(issue.compactDescription): \(issue.element?.debugDescription ?? issue.detailedDescription)")
            return true
        }

        note.tap()
        XCTAssertEqual(noteField(in: app).value as? String, "Venti pagine e un caffè")
        app.buttons["Annulla"].tap()
        XCTAssertTrue(note.waitForExistence(timeout: 5))
    }

    @MainActor
    func testClearingANoteRemovesIt() {
        let app = launch()
        add("Leggere", in: app)
        let leggere = habit("Leggere", in: app)
        leggere.tap()
        app.buttons["Scrivi nota"].tap()
        noteField(in: app).typeText("Ciao")
        app.buttons["Fine"].tap()
        expectValue(leggere, "Da fare, 0 giorni, con nota")

        leggere.tap()
        app.buttons["Modifica nota"].tap()
        let field = noteField(in: app)
        field.tap()
        field.typeText(String(repeating: XCUIKeyboardKey.delete.rawValue, count: 4))
        app.buttons["Fine"].tap()

        expectValue(leggere, "Da fare, 0 giorni")
    }

    @MainActor
    func testEditingAndDeletingAHabit() throws {
        let app = launch()
        add("Leggere", in: app)

        habit("Leggere", in: app).tap()
        app.buttons["Modifica"].tap()
        let titleField = app.textFields["Titolo"]
        XCTAssertTrue(titleField.waitForExistence(timeout: 5))
        titleField.tap()
        XCTAssertTrue(app.keyboards.firstMatch.waitForExistence(timeout: 5))
        titleField.typeText(" ogni sera")
        app.tapButton(app.buttons["Salva abitudine"])
        let edited = habit("Leggere ogni sera", in: app)

        edited.tap()
        app.buttons["Modifica"].tap()
        // Elimina sits at the bottom of the form, past the rows.
        XCTAssertTrue(app.textFields["Titolo"].waitForExistence(timeout: 5))
        app.collectionViews.firstMatch.swipeUp()
        // The confirmation names the habit it deletes.
        try app.tapAndConfirm(app.buttons["Elimina"].firstMatch, question: "Eliminare “Leggere ogni sera”?")
        XCTAssertTrue(app.staticTexts["Aggiungi la prima abitudine"].waitForExistence(timeout: 5))
    }

    @MainActor
    func testStatisticsChangePeriodAndTurnToAHabitsPage() throws {
        let app = launch()
        add("Leggere", in: app)
        add("Camminare", in: app)
        habit("Leggere", in: app).press(forDuration: 1)

        app.buttons["Statistiche"].tap()
        XCTAssertTrue(app.staticTexts["Tutte le abitudini"].waitForExistence(timeout: 5))
        let pages = app.descendants(matching: .any)["statistics-pages"]
        expectValue(pages, "1 di 3")
        // Leggere done today, Camminare not yet: today is not over, so only Leggere counts.
        let figure = app.descendants(matching: .any).matching(NSPredicate(format: "label BEGINSWITH 'Completamento'")).firstMatch
        XCTAssertTrue(figure.label.contains("100%"), figure.label)

        let period = app.buttons["Periodo"]
        expectValue(period, "Dall'inizio")
        period.tap()
        app.buttons["Ultimi 7 giorni"].tap()
        expectValue(period, "Ultimi 7 giorni")

        app.buttons["statistics-Camminare"].tap()
        expectValue(pages, "3 di 3")
        XCTAssertTrue(app.staticTexts["STORICO"].waitForExistence(timeout: 5))
        // Camminare is still to do today: nothing to count yet.
        let nothingYet = app.staticTexts["Niente previsto in questo periodo"].firstMatch
        XCTAssertTrue(nothingYet.exists)

        nothingYet.swipeRight()
        expectValue(pages, "2 di 3")
        try app.performAccessibilityAudit(for: XCUIAccessibilityAuditType.all.subtracting([.contrast, .dynamicType])) { issue in
            XCTFail("\(issue.compactDescription): \(issue.element?.debugDescription ?? issue.detailedDescription)")
            return true
        }

        app.buttons["Chiudi"].tap()
        XCTAssertTrue(habit("Leggere", in: app).waitForExistence(timeout: 5))
    }

    /// The order of the habits lives in Impostazioni, as in Streaks: the list is always ready to drag.
    @MainActor
    func testSettingsReorderTheHabits() throws {
        let app = launch()
        add("Leggere", in: app)
        add("Camminare", in: app)

        app.buttons["Impostazioni"].tap()
        let order = app.buttons["Ordine delle abitudini"]
        XCTAssertTrue(order.waitForExistence(timeout: 5))
        order.tap()

        let leggere = app.cells.containing(.staticText, identifier: "Leggere").firstMatch
        let camminare = app.cells.containing(.staticText, identifier: "Camminare").firstMatch
        XCTAssertTrue(leggere.waitForExistence(timeout: 5))
        XCTAssertLessThan(leggere.frame.minY, camminare.frame.minY)
        XCTAssertTrue(app.buttons.matching(NSPredicate(format: "label BEGINSWITH 'Riordina'")).firstMatch.exists)
        // Text clipped is left out too: in edit mode the audit measures a row's title against
        // the whole row, reorder handle included, and flags text that shows in full.
        try app.performAccessibilityAudit(for: XCUIAccessibilityAuditType.all.subtracting([.contrast, .dynamicType, .textClipped])) { issue in
            XCTFail("\(issue.compactDescription): \(issue.element?.debugDescription ?? issue.detailedDescription)")
            return true
        }
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
        app.buttons["Annulla l'ultimo segno"].tap()
        expectValue(caffe, "Da evitare, 1 su 1, 0 giorni")
    }

    @MainActor
    func testTheFormLinksAHabitToSalute() throws {
        let app = launch()
        app.openHabitForm()
        app.openFormRow("Salute")

        app.toggleSwitch("Collega a Salute")

        app.reveal(app.staticTexts["Si segna da sola quando arrivi all'obiettivo in Salute. Se neghi l'accesso, la segni tu."])
        app.backToForm()
        // The goal has its own row, and the title follows it until you write one.
        let goal = app.formRow("Obiettivo")
        app.reveal(goal)
        XCTAssertTrue("\(goal.label) \(goal.value as? String ?? "")".contains("passi"), goal.debugDescription)
        app.reveal(app.staticTexts["Usa i dati di Salute. Consenti l'accesso se iOS lo chiede."])
        app.reveal(app.descendants(matching: .any).matching(NSPredicate(format: "label CONTAINS 'Camminare 8000 passi'")).firstMatch)
        try app.auditHabitForm()

        app.openFormRow("Obiettivo")
        XCTAssertTrue(app.staticTexts["Obiettivo al giorno"].waitForExistence(timeout: 5))
        try app.auditHabitForm()
        app.backToForm()

        // A habit Salute marks can say so. The box above pushes the row under the bottom button.
        app.openFormRow("Notifiche")
        app.reveal(app.buttons["Nessun promemoria"])
        // Taller with the Salute section, the screen always has a system row cut by the screen
        // edge or the bar, which the audit reports as clipped text with no element, as in Impostazioni.
        try app.performAccessibilityAudit(for: XCUIAccessibilityAuditType.all.subtracting([.contrast, .dynamicType])) { issue in
            if issue.isRowCutByTheScreenEdge {
                return true
            }
            XCTFail("\(issue.compactDescription): \(issue.element?.debugDescription ?? issue.detailedDescription)")
            return true
        }
        app.reveal(app.staticTexts["Ti avvisa quando Salute la segna fatta."])
        app.reveal(app.buttons["Nessuna"])
        XCTAssertTrue(app.buttons["Nessuna"].isSelected)
        app.backToForm()
        // Linking for real would show iOS's Salute sheet: the test stops before Aggiungi abitudine.
        app.cancelNewHabit()
    }

    @MainActor
    func testTheSaluteScreenListsEveryMeasureByGroup() throws {
        let app = launch()
        app.openHabitForm()
        app.openFormRow("Salute")
        app.toggleSwitch("Collega a Salute")

        // Passi is chosen to start with; the groups follow the toggle.
        app.reveal(app.buttons["Passi"])
        XCTAssertTrue(app.buttons["Passi"].isSelected)
        app.reveal(app.staticTexts.matching(NSPredicate(format: "label ==[c] 'Attività'")).firstMatch)
        try app.auditHabitForm()

        let stand = app.buttons["Minuti in piedi"]
        app.tapButton(stand)
        XCTAssertTrue(stand.isSelected)
        app.reveal(app.buttons["Passi"])
        XCTAssertFalse(app.buttons["Passi"].isSelected)

        // The last groups are below the screen's edge.
        app.reveal(app.buttons["Sonno"])
        app.reveal(app.buttons["Acqua"])
        try app.auditHabitForm()

        app.tapButton(app.buttons["Anelli Attività"])
        app.backToForm()
        let goal = app.formRow("Obiettivo")
        app.reveal(goal)
        XCTAssertTrue("\(goal.label) \(goal.value as? String ?? "")".contains("3 anelli"), goal.debugDescription)
        app.reveal(app.descendants(matching: .any).matching(NSPredicate(format: "label CONTAINS 'Chiudere 3 anelli'")).firstMatch)
        app.cancelNewHabit()
    }

    @MainActor
    func testALinkedHabitWithoutAccessIsMarkedByHand() {
        let app = launch()
        app.openHabitForm()
        app.openFormRow("Salute")
        app.toggleSwitch("Collega a Salute")
        app.backToForm()
        app.typeTitleAndAdd("Camminare")

        // iOS asks only the first time on this simulator, in the system's language; deny it, as a
        // person may.
        let deny = app.buttons["UIA.Health.DoNotAllow.Button"]
        if deny.waitForExistence(timeout: 5) {
            deny.tap()
            // iOS then explains where to turn access on later.
            let explained = app.alerts.firstMatch.buttons.firstMatch
            if explained.waitForExistence(timeout: 5) {
                explained.tap()
            }
        }

        let camminare = habit("Camminare", in: app)
        expectValue(camminare, "Da fare, 0 giorni, collegata a Salute")
        camminare.press(forDuration: 1)
        expectValue(camminare, "Fatta, 1 giorno, collegata a Salute")
    }

    /// iOS asks for notifications the first time on this simulator, over the app: allow them.
    @MainActor
    private func allowNotificationsIfAsked() {
        let alert = XCUIApplication(bundleIdentifier: "com.apple.springboard").alerts.firstMatch
        if alert.waitForExistence(timeout: 3) {
            alert.buttons.element(boundBy: 1).tap()
        }
    }

    @MainActor
    private func addTimed(_ title: String, in app: XCUIApplication) {
        app.openHabitForm()
        app.openFormRow("Tipo")
        app.tapButton(app.buttons["A tempo"])
        allowNotificationsIfAsked()
        app.backToForm()
        app.reveal(app.formRow("Durata"))
        app.typeTitleAndAdd(title)
    }

    /// The Notifiche screen's toggle: the row's right edge, where the switch is.
    @MainActor
    private func toggleTimeSensitive(in app: XCUIApplication) -> XCUIElement {
        let toggle = app.switches["Sensibili al tempo"]
        app.reveal(toggle)
        return toggle
    }

    /// The Suono row, a picker: its choice is its label or its value.
    @MainActor
    private func soundRowSays(_ sound: String, in app: XCUIApplication) -> Bool {
        let row = app.formRow("Suono")
        return row.label.contains(sound) || (row.value as? String)?.contains(sound) == true
    }

    @MainActor
    func testTheNotificheScreenKeepsAutomaticTimesTimeSensitiveAndASound() throws {
        let app = launch()
        app.openHabitForm()
        app.openFormRow("Notifiche")

        app.tapButton(app.buttons["Orari automatici"])
        allowNotificationsIfAsked()
        app.reveal(app.staticTexts["Ti ricorda all'ora in cui di solito la fai, se oggi non è ancora fatta."])
        let toggle = toggleTimeSensitive(in: app)
        toggle.coordinate(withNormalizedOffset: CGVector(dx: 0.9, dy: 0.5)).tap()
        XCTAssertEqual(toggle.value as? String, "1")
        try app.auditHabitForm()
        app.tapButton(app.formRow("Suono"))
        app.tapButton(app.buttons["Carta"])
        app.reveal(app.formRow("Suono"))
        XCTAssertTrue(soundRowSays("Carta", in: app), app.formRow("Suono").debugDescription)
        app.backToForm()
        app.reveal(app.formRow("Notifiche"))
        XCTAssertTrue(app.formRow("Notifiche").label.contains("Automatici"), app.formRow("Notifiche").label)
        app.typeTitleAndAdd("Leggere")

        habit("Leggere", in: app).tap()
        app.buttons["Modifica"].tap()
        app.reveal(app.formRow("Notifiche"))
        XCTAssertTrue(app.formRow("Notifiche").label.contains("Automatici"), app.formRow("Notifiche").label)
        app.openFormRow("Notifiche")
        app.reveal(app.buttons["Orari automatici"])
        XCTAssertTrue(app.buttons["Orari automatici"].isSelected)
        XCTAssertEqual(toggleTimeSensitive(in: app).value as? String, "1")
        app.reveal(app.formRow("Suono"))
        XCTAssertTrue(soundRowSays("Carta", in: app), app.formRow("Suono").debugDescription)
    }

    @MainActor
    func testATimedHabitRunsItsTimerPausesAndCancels() throws {
        let app = launch()
        addTimed("Leggere", in: app)
        let leggere = habit("Leggere", in: app)
        expectValue(leggere, "Da fare, 10 minuti, 0 giorni")

        app.buttons["Avvia Leggere"].tap()
        allowNotificationsIfAsked()

        let left = app.descendants(matching: .any)["Tempo rimanente"]
        XCTAssertTrue(left.waitForExistence(timeout: 5))
        XCTAssertTrue(app.staticTexts["Leggere"].exists || app.otherElements["Leggere"].exists)
        app.buttons["Pausa"].tap()
        XCTAssertTrue(app.buttons["Riprendi"].waitForExistence(timeout: 5))
        let paused = left.value as? String
        // Paused, the time left stays put.
        Thread.sleep(forTimeInterval: 1.5)
        XCTAssertEqual(left.value as? String, paused)

        // Contrast is left out as on the tool screen.
        try app.performAccessibilityAudit(for: XCUIAccessibilityAuditType.all.subtracting(.contrast)) { issue in
            XCTFail("\(issue.compactDescription): \(issue.element?.debugDescription ?? issue.detailedDescription)")
            return true
        }

        app.buttons["Riprendi"].tap()
        XCTAssertTrue(app.buttons["Pausa"].waitForExistence(timeout: 5))
        app.buttons["Annulla"].tap()

        XCTAssertTrue(left.waitForNonExistence(timeout: 5))
        expectValue(leggere, "Da fare, 10 minuti, 0 giorni")
    }

    @MainActor
    func testSegnaFattaEndsTheTimerAndMarksTheHabit() {
        let app = launch()
        addTimed("Meditare", in: app)
        app.buttons["Avvia Meditare"].tap()
        allowNotificationsIfAsked()
        XCTAssertTrue(app.buttons["Segna come fatta"].waitForExistence(timeout: 5))

        app.buttons["Segna come fatta"].tap()

        expectValue(habit("Meditare", in: app), "Fatta, 10 minuti, 1 giorno")
        XCTAssertFalse(app.buttons["Avvia Meditare"].exists)
    }

    @MainActor
    func testARunningTimerSurvivesARelaunch() {
        var app = launch()
        addTimed("Leggere", in: app)
        app.buttons["Avvia Leggere"].tap()
        allowNotificationsIfAsked()
        XCTAssertTrue(app.buttons["Pausa"].waitForExistence(timeout: 5))

        app.terminate()
        app = launch()

        XCTAssertTrue(app.buttons["Pausa"].waitForExistence(timeout: 5))
        app.buttons["Annulla"].tap()
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
            XCTFail("\(issue.compactDescription): \(issue.element?.debugDescription ?? issue.detailedDescription)")
            return true
        }
    }

    /// Six places a page: the seventh habit goes to page 2, reached with a swipe. At the
    /// accessibility text sizes the grid is one column with no pages, so this runs at the default.
    @MainActor
    func testTheSecondPageIsReachedWithASwipeAndPassesTheAccessibilityAudit() throws {
        let app = launch(defaultTextSize: true)
        for title in ["Uno", "Due", "Tre", "Quattro", "Cinque", "Sei"] {
            add(title, in: app)
        }
        let dots = app.descendants(matching: .any)["Pagina"]
        XCTAssertTrue(dots.waitForExistence(timeout: 5))
        expectValue(dots, "1 di 2")
        // Every habit stays in the accessibility tree, the ones on other pages too.
        XCTAssertTrue(app.buttons["Aggiungi"].exists)

        app.scrollViews.firstMatch.swipeLeft()

        expectValue(dots, "2 di 2")
        add("Sette", in: app)
        let sette = habit("Sette", in: app)
        XCTAssertTrue(sette.isHittable)
        sette.press(forDuration: 1)
        expectValue(sette, "Fatta, 1 giorno")
        // Contrast is left out as on the first page.
        try app.performAccessibilityAudit(for: XCUIAccessibilityAuditType.all.subtracting(.contrast)) { issue in
            XCTFail("\(issue.compactDescription): \(issue.element?.debugDescription ?? issue.detailedDescription)")
            return true
        }

        app.scrollViews.firstMatch.swipeRight()

        expectValue(dots, "1 di 2")
        XCTAssertTrue(habit("Uno", in: app).isHittable)
    }

    @MainActor
    func testSettingsOfferExportAndImportAndPassTheAccessibilityAudit() throws {
        let app = launch()
        add("Leggere", in: app)

        app.buttons["Impostazioni"].tap()
        let export = app.buttons["Esporta"]
        app.reveal(export)
        XCTAssertTrue(export.isEnabled)
        app.reveal(app.buttons["Importa"])
        XCTAssertTrue(app.buttons["Importa"].isEnabled)

        // Contrast is left out as on the tool screen. Dynamic Type too: in the settings sheet the
        // audit flags every text as partially unsupported, system ones included (the Fine button,
        // a plain section footer), so it says nothing about this screen.
        try app.performAccessibilityAudit(for: XCUIAccessibilityAuditType.all.subtracting([.contrast, .dynamicType])) { issue in
            XCTFail("\(issue.compactDescription): \(issue.element?.debugDescription ?? issue.detailedDescription)")
            return true
        }
    }

    /// Without iCloud, as on a simulator signed out: the switch is off, cannot be turned on, and
    /// the footer says why.
    @MainActor
    func testWithoutICloudTheSyncSwitchIsOffAndSaysWhy() throws {
        let app = launch()

        app.buttons["Impostazioni"].tap()
        let toggle = app.switches["Sincronizza con iCloud"]
        app.reveal(toggle)
        XCTAssertEqual(toggle.value as? String, "0")
        XCTAssertFalse(toggle.isEnabled)
        XCTAssertTrue(app.staticTexts["Per sincronizzare, accedi a iCloud e attiva iCloud Drive nelle Impostazioni dell'iPhone."].waitForExistence(timeout: 5))
        app.reveal(app.buttons["Esporta"])
        XCTAssertTrue(app.buttons["Esporta"].isEnabled)

        // As in testSettingsOfferExportAndImportAndPassTheAccessibilityAudit.
        try app.performAccessibilityAudit(for: XCUIAccessibilityAuditType.all.subtracting([.contrast, .dynamicType])) { issue in
            XCTFail("\(issue.compactDescription): \(issue.element?.debugDescription ?? issue.detailedDescription)")
            return true
        }
    }

    /// With iCloud the switch starts off, in Dati above Esporta, and turns on.
    @MainActor
    func testWithICloudTheSyncSwitchStartsOffAndTurnsOn() throws {
        let app = launch(iCloud: true)

        app.buttons["Impostazioni"].tap()
        let toggle = app.switches["Sincronizza con iCloud"]
        app.reveal(toggle)
        XCTAssertEqual(toggle.value as? String, "0")
        XCTAssertTrue(toggle.isEnabled)
        XCTAssertTrue(app.staticTexts.matching(NSPredicate(format: "label BEGINSWITH 'Le abitudini e lo storico vanno sul tuo iCloud, mai a sbu.dev'")).firstMatch.waitForExistence(timeout: 5))

        toggle.switches.firstMatch.tap()

        expectValue(toggle, "1")
        try app.performAccessibilityAudit(for: XCUIAccessibilityAuditType.all.subtracting([.contrast, .dynamicType])) { issue in
            XCTFail("\(issue.compactDescription): \(issue.element?.debugDescription ?? issue.detailedDescription)")
            return true
        }
    }
}
