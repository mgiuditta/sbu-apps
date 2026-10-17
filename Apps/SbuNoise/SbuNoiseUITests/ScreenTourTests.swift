import XCTest

/// Not a check: walks through every screen, sheet, empty state and warning of the catalog, the
/// alarm and the bedside clock and attaches a screenshot of each, to look at them in light, dark,
/// English and the largest text sizes (set on the simulator before running; English with
/// `TEST_RUNNER_TOUR_LANG=en`). Skipped in the SbuNoise scheme, like SnapshotTests.
final class ScreenTourTests: XCTestCase {
    private var english: Bool { ProcessInfo.processInfo.environment["TOUR_LANG"] == "en" }

    @MainActor
    func testTour() throws {
        let app = launch()

        snap(app, "01-player")
        tap(app, "Categorie", "Categories")
        snap(app, "02-menu")
        tap(app, "Preferiti", "Favorites")
        snap(app, "03-preferiti-vuoti")
        tap(app, "Categorie", "Categories")
        tap(app, "Mix", "Mixes")
        snap(app, "04-mix-vuoti")
        tap(app, "Categorie", "Categories")
        tap(app, "Suoni", "Sounds")

        tap(app, "Informazioni", "Info")
        snap(app, "05-info")
        tap(app, "Fine", "Done")

        tap(app, "Gestisci", "Manage")
        snap(app, "06-gestisci")
        tap(app, "Filtra", "Filter")
        snap(app, "07-gestisci-filtro")
        tap(app, "Acqua", "Water")
        snap(app, "08-gestisci-acqua")
        app.searchFields.firstMatch.tap()
        app.searchFields.firstMatch.typeText("zzz\n")
        snap(app, "09-gestisci-nessun-risultato")
        // The active search hides the toolbar: close the search first.
        let closeSearch = app.buttons.matching(NSPredicate(format: "label IN %@", ["Annulla", "Chiudi", "Cancel", "Close"])).firstMatch
        if closeSearch.waitForExistence(timeout: 2) { closeSearch.tap() }
        tap(app, "Fine", "Done")

        tap(app, "Crea", "Create")
        tap(app, "Nuovo mix", "New Mix")
        snap(app, "10-scegli-suoni")
        tap(app, "Annulla", "Cancel")

        tap(app, "Timer", "Timers")
        snap(app, "11-timer-vuoti")
        tap(app, "Nuovo timer", "New Timer")
        tap(app, "Salva", "Save")
        tap(app, "Aggiungi", "Add")
        tap(app, "Nuova sveglia", "New Alarm")
        snap(app, "12-nuova-sveglia")
        app.buttons.matching(NSPredicate(format: "label BEGINSWITH %@", english ? "Sound" : "Suono")).firstMatch.tap()
        snap(app, "13-suono-sveglia")
        app.navigationBars[english ? "Sound" : "Suono"].buttons.firstMatch.tap()
        tap(app, "Salva", "Save")
        snap(app, "14-timer-e-sveglie")
        tap(app, "Fine", "Done")
        snap(app, "15-player-con-righe")

        tap(app, "Dormi", "Sleep")
        snap(app, "16-orologio")
        tap(app, "Chiudi", "Close")

        tap(app, "Impostazioni", "Settings")
        snap(app, "17-impostazioni")
        tap(app, "Crediti dei suoni", "Sound Credits")
        snap(app, "18-crediti")
    }

    @MainActor
    func testRinging() throws {
        let app = launch(environment: ["SBU_NOISE_RING": "1"])
        _ = app.buttons[english ? "Stop" : "Ferma"].waitForExistence(timeout: 5)
        snap(app, "19-sveglia")
        tap(app, "Ferma", "Stop")
    }

    @MainActor
    func testPermissionDenied() throws {
        let app = launch(environment: ["SBU_NOISE_BACKUP": "denied"])
        tap(app, "Timer", "Timers")
        tap(app, "Aggiungi", "Add")
        tap(app, "Nuova sveglia", "New Alarm")
        snap(app, "20-permesso-negato")
    }

    @MainActor
    private func launch(environment: [String: String] = [:]) -> XCUIApplication {
        let app = XCUIApplication()
        app.launchArguments = english
            ? ["-AppleLanguages", "(en)", "-AppleLocale", "en_US"]
            : ["-AppleLanguages", "(it)", "-AppleLocale", "it_IT"]
        app.launchArguments += ["-lastCategory", "sounds", "-lastSoundID", "rain.heavy"]
        app.launchEnvironment["SBU_NOISE_FILE"] = "ui-\(UUID().uuidString).json"
        app.launchEnvironment["SBU_NOISE_BACKUP"] = "silent"
        for (key, value) in environment { app.launchEnvironment[key] = value }
        app.launch()
        return app
    }

    @MainActor
    private func tap(_ app: XCUIApplication, _ italian: String, _ english: String) {
        let button = app.buttons[self.english ? english : italian].firstMatch
        _ = button.waitForExistence(timeout: 3)
        button.tap()
    }

    @MainActor
    private func snap(_ app: XCUIApplication, _ name: String) {
        sleep(1)
        let attachment = XCTAttachment(screenshot: app.screenshot())
        attachment.name = name
        attachment.lifetime = .keepAlways
        add(attachment)
    }
}
