import XCTest

/// Walks every screen, sheet and dialog with the demo habits and keeps a screenshot of each, for
/// a visual review in light and dark, Italian and English, at any text size and on any iPhone.
/// It asserts nothing: it runs only when the runner's environment sets `SBU_TOUR`, as in
/// `TEST_RUNNER_SBU_TOUR=1 TEST_RUNNER_SBU_TOUR_LANGUAGE=en TEST_RUNNER_SBU_TOUR_SIZE=
/// UICTContentSizeCategoryAccessibilityXXXL xcodebuild test -only-testing:SbuHabitsUITests/ScreenTourTests`.
final class ScreenTourTests: XCTestCase {
    private var app = XCUIApplication()
    private var isEnglish = false

    override func setUpWithError() throws {
        let environment = ProcessInfo.processInfo.environment
        try XCTSkipUnless(environment["SBU_TOUR"] != nil, "Set SBU_TOUR to take the screen tour.")
        continueAfterFailure = true
        isEnglish = environment["SBU_TOUR_LANGUAGE"] == "en"
        app.launchArguments += isEnglish
            ? ["-AppleLanguages", "(en)", "-AppleLocale", "en_US"]
            : ["-AppleLanguages", "(it)", "-AppleLocale", "it_IT"]
        if let size = environment["SBU_TOUR_SIZE"] {
            app.launchArguments += ["-UIPreferredContentSizeCategoryName", size]
        }
        // The demo habits, and one habit someone shares.
        app.launchArguments += ["-FASTLANE_SNAPSHOT", "YES"]
        app.launchEnvironment["SBU_HABITS_SHARED_FILE"] = "tour-shared-\(UUID().uuidString).json"
        app.launchEnvironment["SBU_HABITS_SHARED_DEMO"] = "1"
    }

    @MainActor
    func testTour() {
        app.launch()
        _ = button("Impostazioni", "Settings").waitForExistence(timeout: 10)
        shot("01-grid")

        tourSettings()
        tourStatistics()
        tourHabitMenu()
        tourSharedHabit()
        tourAdd()
        tourForm()
        tourTimed()
        tourEditAndDelete()
    }

    // MARK: - Parts

    @MainActor
    private func tourSettings() {
        tap(button("Impostazioni", "Settings"))
        shot("02-settings")
        scrollDown(times: 2, named: "02-settings")
        tap(button("Ordine delle abitudini", "Habit order"))
        shot("03-order")
        back()
        tap(button("Fine", "Done"))
    }

    @MainActor
    private func tourStatistics() {
        tap(button("Statistiche", "Statistics"))
        shot("04-statistics")
        scrollDown(times: 3, named: "04-statistics")
        app.scrollViews.firstMatch.swipeLeft()
        shot("05-statistics-habit")
        scrollDown(times: 4, named: "05-statistics-habit")
        tapFirstExisting([button("Fine", "Done"), button("Chiudi", "Close")])
    }

    @MainActor
    private func tourHabitMenu() {
        tap(button("Opzioni di Leggere", "Options for Read"))
        shot("06-habit-menu")
        tap(button("Scrivi nota", "Write note"))
        shot("07-note")
        tap(button("Annulla", "Cancel"))
    }

    @MainActor
    private func tourSharedHabit() {
        let shared = cell("Correre")
        reveal(shared)
        tap(shared)
        shot("09-shared-screen")
        scrollDown(times: 4, named: "09-shared-screen")
        let remove = button("Rimuovi", "Remove")
        tap(remove)
        shot("10-shared-remove-confirm")
        // Away from the confirmation, without removing: the alert's Annulla, or outside the bubble.
        let cancel = app.alerts.buttons[isEnglish ? "Cancel" : "Annulla"]
        if cancel.exists {
            cancel.tap()
        } else {
            app.navigationBars.firstMatch.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5)).tap()
        }
        tap(button("Fine", "Done"))
    }

    @MainActor
    private func tourAdd() {
        let add = button("Aggiungi", "Add")
        reveal(add)
        tap(add)
        shot("11-add-general")
        for (index, tab) in [("Salute", "Health"), ("Alimentazione", "Food"), ("A tempo", "Timed"), ("Da evitare", "To avoid")].enumerated() {
            tap(button(tab.0, tab.1))
            shot("12-add-tab-\(index + 1)")
        }
        tap(button("Cerca", "Search"))
        let search = app.searchFields.firstMatch
        guard search.waitForExistence(timeout: 5) else { return }
        search.tap()
        search.typeText("zzzz")
        shot("13-add-search-empty")
        search.buttons.firstMatch.tap()
        search.typeText(isEnglish ? "read" : "leggere")
        shot("14-add-search-results")
        // The form, from the first result.
        tap(app.buttons.matching(NSPredicate(format: "label BEGINSWITH %@", isEnglish ? "Read" : "Leggere")).firstMatch)
    }

    @MainActor
    private func tourForm() {
        shot("15-form")
        scrollDown(times: 3, named: "15-form")
        for (index, row) in [("Tipo", "Type"), ("Obiettivo", "Goal"), ("Giorni", "Days"), ("Notifiche", "Notifications"), ("Salute", "Health")].enumerated() {
            let formRow = app.buttons.matching(NSPredicate(format: "label BEGINSWITH %@", isEnglish ? row.1 : row.0)).firstMatch
            reveal(formRow)
            tap(formRow)
            shot("16-form-row-\(index + 1)")
            scrollDown(times: 2, named: "16-form-row-\(index + 1)")
            back()
        }
        let symbol = button("Cambia simbolo", "Change symbol")
        reveal(symbol)
        tap(symbol)
        shot("17-symbol-picker")
        tapFirstExisting([button("Annulla", "Cancel"), button("Fine", "Done"), button("Chiudi", "Close")])
        back()
        shot("17-back-to-search")
        // The search's own close, then the sheet's.
        tapFirstExisting([button("Chiudi", "Close")])
        shot("17-search-closed")
        tapFirstExisting([button("Chiudi", "Close")])
    }

    @MainActor
    private func tourTimed() {
        let add = button("Aggiungi", "Add")
        reveal(add)
        tap(add)
        shot("18-add-reopened")
        tap(button("A tempo", "Timed"))
        let reading = app.buttons.matching(NSPredicate(format: "label BEGINSWITH %@", isEnglish ? "Play an instrument" : "Suonare uno strumento")).firstMatch
        reveal(reading)
        tap(reading)
        allowNotificationsIfAsked()
        let confirm = button("Aggiungi abitudine", "Add habit")
        reveal(confirm)
        tap(confirm)
        allowNotificationsIfAsked()
        shot("18-grid-with-timed")
        let start = app.buttons.matching(NSPredicate(format: "label BEGINSWITH %@", isEnglish ? "Start" : "Avvia")).firstMatch
        reveal(start)
        tap(start)
        allowNotificationsIfAsked()
        shot("19-timer")
        tapFirstExisting([button("Pausa", "Pause")])
        shot("20-timer-paused")
        tapFirstExisting([button("Annulla", "Cancel")])
    }

    @MainActor
    private func tourEditAndDelete() {
        let water = cell(isEnglish ? "Drink water" : "Bere acqua")
        reveal(water)
        tap(button("Opzioni di Bere acqua", "Options for Drink water"))
        tap(button("Modifica", "Edit"))
        shot("21-edit")
        let delete = button("Elimina", "Delete")
        reveal(delete)
        shot("22-edit-bottom")
        tap(delete)
        shot("23-delete-confirm")
    }

    // MARK: - Helpers

    @MainActor
    private func button(_ italian: String, _ english: String) -> XCUIElement {
        app.buttons[isEnglish ? english : italian].firstMatch
    }

    @MainActor
    private func cell(_ title: String) -> XCUIElement {
        app.descendants(matching: .any).matching(identifier: title).firstMatch
    }

    @MainActor
    private func tap(_ element: XCUIElement) {
        guard element.waitForExistence(timeout: 5) else { return }
        if element.isHittable {
            element.tap()
        } else {
            reveal(element)
            if element.isHittable {
                element.tap()
            }
        }
    }

    @MainActor
    private func tapFirstExisting(_ elements: [XCUIElement]) {
        if let element = elements.first(where: { $0.exists && $0.isHittable }) {
            element.tap()
        }
    }

    @MainActor
    private func back() {
        let bar = app.navigationBars.allElementsBoundByIndex.last ?? app.navigationBars.firstMatch
        let first = bar.buttons.element(boundBy: 0)
        if first.exists {
            first.tap()
        }
    }

    /// Scrolls whatever scrolls on screen until the element is hittable, down then up.
    @MainActor
    private func reveal(_ element: XCUIElement) {
        let list = app.collectionViews.firstMatch.exists ? app.collectionViews.firstMatch : app.scrollViews.firstMatch
        for _ in 0..<8 where element.isHittable == false {
            list.swipeUp()
        }
        for _ in 0..<8 where element.isHittable == false {
            list.swipeDown()
        }
    }

    /// One screenshot after each swipe up, then back to the top.
    @MainActor
    private func scrollDown(times: Int, named name: String) {
        let list = app.collectionViews.firstMatch.exists ? app.collectionViews.firstMatch : app.scrollViews.firstMatch
        for step in 1...times where list.exists {
            list.swipeUp()
            shot("\(name)-\(step)")
        }
        for _ in 1...times where list.exists {
            list.swipeDown()
        }
    }

    @MainActor
    private func allowNotificationsIfAsked() {
        let alert = XCUIApplication(bundleIdentifier: "com.apple.springboard").alerts.firstMatch
        if alert.waitForExistence(timeout: 2) {
            alert.buttons.element(boundBy: 1).tap()
        }
    }

    @MainActor
    private func shot(_ name: String) {
        // Lets animations end.
        _ = app.wait(for: .runningForeground, timeout: 1)
        Thread.sleep(forTimeInterval: 0.6)
        let attachment = XCTAttachment(screenshot: app.screenshot())
        attachment.name = name
        attachment.lifetime = .keepAlways
        add(attachment)
    }
}
