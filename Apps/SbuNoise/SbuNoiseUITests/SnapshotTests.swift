import XCTest

/// Drives the App Store screenshots for `fastlane snapshot`.
/// A sound playing, the privacy promise in settings, the sounds to choose from, an alarm, then
/// the bedside clock. Runs on a throwaway file, so the alarm is its own.
final class SnapshotTests: XCTestCase {
    @MainActor
    func testScreenshots() {
        let app = XCUIApplication()
        setupSnapshot(app)
        app.launchArguments += ["-lastCategory", "sounds", "-lastSoundID", "rain.light"]
        app.launchEnvironment["SBU_NOISE_FILE"] = "snapshot-\(UUID().uuidString).json"
        app.launchEnvironment["SBU_NOISE_BACKUP"] = "silent"
        app.launch()

        let play = button("Riproduci", "Play", in: app)
        XCTAssertTrue(play.waitForExistence(timeout: 5))
        play.tap()
        snapshot("01-main")

        button("Impostazioni", "Settings", in: app).tap()
        // The promises close the settings, under Icona and Suono.
        let sbuDev = app.descendants(matching: .any).matching(NSPredicate(format: "label BEGINSWITH 'Parte di sbu.dev' OR label BEGINSWITH 'Part of sbu.dev'")).firstMatch
        for _ in 0..<6 where !sbuDev.isHittable {
            app.swipeUp()
        }
        snapshot("02-privacy")
        tap("Fine", "Done", in: app)

        tap("Gestisci", "Manage", in: app)
        sleep(1)
        snapshot("03-sounds")
        tap("Fine", "Done", in: app)

        tap("Timer", "Timers", in: app)
        // Only the alarm: a timer that stops the sound first would show the warning that the
        // alarm then comes as a notification.
        tap("Aggiungi", "Add", in: app)
        tap("Nuova sveglia", "New Alarm", in: app)
        tap("Salva", "Save", in: app)
        sleep(1)
        snapshot("04-alarm")
        tap("Fine", "Done", in: app)

        tap("Dormi", "Sleep", in: app)
        sleep(1)
        snapshot("05-clock")
    }

    /// The Italian button, or the English one when the run is in English.
    @MainActor
    private func button(_ italian: String, _ english: String, in app: XCUIApplication) -> XCUIElement {
        let italianButton = app.buttons[italian].firstMatch
        _ = italianButton.waitForExistence(timeout: 3)
        return italianButton.exists ? italianButton : app.buttons[english].firstMatch
    }

    @MainActor
    private func tap(_ italian: String, _ english: String, in app: XCUIApplication) {
        let target = button(italian, english, in: app)
        _ = target.waitForExistence(timeout: 5)
        target.tap()
    }
}
