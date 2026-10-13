import XCTest

// TEMPORARY: screenshots for the UI decisions A–G. Not committed.
final class ZZDecisionTour: XCTestCase {
    private var folder: String {
        ProcessInfo.processInfo.environment["TOUR_OUT"] ?? "/private/tmp/claude-501/-Users-matteo-dev-sbu-apps/dcc7f6f5-912f-4f14-b9c9-e34d5bcd55cd/scratchpad/build/habits-ui-decisions/after/raw"
    }

    override func setUp() {
        continueAfterFailure = true
    }

    @MainActor
    private func launch(_ file: String, english: Bool = false, iCloud: Bool = false) -> XCUIApplication {
        let app = XCUIApplication()
        app.launchArguments += english ? ["-AppleLanguages", "(en)", "-AppleLocale", "en_US"] : ["-AppleLanguages", "(it)", "-AppleLocale", "it_IT"]
        app.launchEnvironment["SBU_HABITS_FILE"] = file
        if iCloud {
            app.launchEnvironment["SBU_HABITS_ICLOUD"] = "available"
        }
        app.launch()
        return app
    }

    @MainActor
    private func shot(_ name: String) {
        sleep(1)
        let data = XCUIScreen.main.screenshot().pngRepresentation
        try? FileManager.default.createDirectory(atPath: folder, withIntermediateDirectories: true)
        let prefix = ProcessInfo.processInfo.environment["TOUR_PREFIX"] ?? ""
        FileManager.default.createFile(atPath: "\(folder)/\(prefix)\(name).png", contents: data)
    }

    @MainActor
    func testHome() {
        _ = launch("dec-many.json")
        shot("B-home-many")
        let app = launch("dec-full.json")
        shot("B-home-full-p1")
        app.swipeLeft()
        shot("B-home-full-p2")
    }

    @MainActor
    func testStatistics() {
        let app = launch("dec-stats.json")
        app.buttons["Statistiche"].tap()
        sleep(1)
        app.swipeLeft()
        shot("C-stats-nothing-due")
        app.swipeUp()
        shot("C-F-stats-nothing-due-scrolled")
        app.swipeDown()
        app.otherElements["Periodo"].firstMatch.tap()
        let week = app.buttons["Ultimi 7 giorni"].firstMatch
        if week.waitForExistence(timeout: 3) == false {
            app.buttons["Periodo"].firstMatch.tap()
        }
        app.buttons["Ultimi 7 giorni"].firstMatch.tap()
        sleep(1)
        app.swipeLeft()
        shot("G-stats-weekly")
        app.swipeUp()
        shot("F-G-stats-weekly-scrolled")
        app.swipeDown()
        app.swipeLeft()
        shot("G-stats-monthly")
        app.swipeUp()
        shot("G-stats-monthly-scrolled")
    }

    @MainActor
    func testSettingsICloud() {
        let app = launch("dec-empty.json", iCloud: true)
        app.buttons["Impostazioni"].firstMatch.tap()
        let toggle = app.switches["Sincronizza con iCloud"].firstMatch
        XCTAssertTrue(toggle.waitForExistence(timeout: 5))
        if (toggle.value as? String) != "1" {
            toggle.switches.firstMatch.tap()
        }
        sleep(1)
        app.swipeUp()
        app.swipeUp()
        shot("A-settings-icloud-on")
        toggle.switches.firstMatch.tap()
        sleep(1)
        app.swipeUp()
        shot("A-settings-icloud-off")
    }

    @MainActor
    func testSettingsICloudEnglish() {
        let app = launch("dec-empty.json", english: true, iCloud: true)
        app.buttons["Settings"].firstMatch.tap()
        let toggle = app.switches["Sync with iCloud"].firstMatch
        XCTAssertTrue(toggle.waitForExistence(timeout: 5))
        if (toggle.value as? String) != "1" {
            toggle.switches.firstMatch.tap()
        }
        sleep(1)
        app.swipeUp()
        app.swipeUp()
        shot("A-settings-icloud-on-en")
        toggle.switches.firstMatch.tap()
    }

    @MainActor
    func testGiorni() {
        let app = launch("dec-empty.json")
        app.openHabitForm()
        app.openFormRow("Giorni")
        app.buttons["Volte a settimana"].tap()
        shot("D-giorni-weekly")
        app.buttons["Volte al mese"].tap()
        shot("D-giorni-monthly")
    }

    @MainActor
    func testSaluteSymbol() {
        let app = launch("dec-empty.json")
        app.openHabitForm()
        shot("E-form-new-before-link")
        app.openFormRow("Salute")
        let toggle = app.switches["Collega a Salute"].firstMatch
        XCTAssertTrue(toggle.waitForExistence(timeout: 5))
        toggle.switches.firstMatch.tap()
        sleep(1)
        shot("E-salute-linked")
        app.backToForm()
        shot("E-form-new-linked-steps")
    }
}
