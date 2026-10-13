import XCTest

/// Not a check: walks through the screens of the catalog, the alarm and the bedside clock and
/// attaches a screenshot of each, to look at them in light, dark and the largest text size
/// (set on the simulator before running). Skipped in the SbuNoise scheme, like SnapshotTests.
final class ScreenTourTests: XCTestCase {
    @MainActor
    func testTour() throws {
        let app = XCUIApplication()
        app.launchArguments = ["-AppleLanguages", "(it)", "-AppleLocale", "it_IT", "-lastCategory", "sounds", "-lastSoundID", "rain.heavy"]
        app.launchEnvironment["SBU_NOISE_FILE"] = "ui-\(UUID().uuidString).json"
        app.launchEnvironment["SBU_NOISE_BACKUP"] = "silent"
        app.launch()

        snap(app, "01-player")
        app.buttons["Informazioni"].tap()
        snap(app, "02-info")
        app.buttons["Fine"].tap()

        app.buttons["Gestisci"].tap()
        snap(app, "03-gestisci")
        app.buttons["Fine"].tap()

        app.buttons["Timer"].tap()
        app.buttons["Aggiungi"].tap()
        app.buttons["Nuova sveglia"].tap()
        snap(app, "04-nuova-sveglia")
        app.buttons["Salva"].tap()
        snap(app, "05-timer-e-sveglie")
        app.buttons["Fine"].tap()
        snap(app, "06-player-con-sveglia")

        app.buttons["Dormi"].tap()
        snap(app, "07-orologio")
        app.buttons["Chiudi"].tap()

        app.buttons["Impostazioni"].tap()
        app.buttons["Crediti dei suoni"].tap()
        snap(app, "08-crediti")
    }

    @MainActor
    func testRinging() throws {
        let app = XCUIApplication()
        app.launchArguments = ["-AppleLanguages", "(it)", "-AppleLocale", "it_IT"]
        app.launchEnvironment["SBU_NOISE_FILE"] = "ui-\(UUID().uuidString).json"
        app.launchEnvironment["SBU_NOISE_BACKUP"] = "silent"
        app.launchEnvironment["SBU_NOISE_RING"] = "1"
        app.launch()
        _ = app.buttons["Ferma"].waitForExistence(timeout: 5)
        snap(app, "09-sveglia")
        app.buttons["Ferma"].tap()
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
