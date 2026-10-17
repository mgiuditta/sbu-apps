import XCTest

/// Drives the App Store screenshots for `fastlane snapshot`.
/// First a sound playing, then the privacy promise in settings.
final class SnapshotTests: XCTestCase {
    @MainActor
    func testScreenshots() {
        let app = XCUIApplication()
        setupSnapshot(app)
        app.launchArguments += ["-lastCategory", "sounds", "-lastSoundID", "rain.light"]
        app.launch()

        let play = app.buttons["Riproduci"].exists ? app.buttons["Riproduci"] : app.buttons["Play"]
        XCTAssertTrue(play.waitForExistence(timeout: 5))
        play.tap()
        snapshot("01-main")

        let settings = app.buttons["Impostazioni"].exists ? app.buttons["Impostazioni"] : app.buttons["Settings"]
        settings.tap()
        // The promises close the settings, under Icona and Suono.
        let sbuDev = app.descendants(matching: .any).matching(NSPredicate(format: "label BEGINSWITH 'Parte di sbu.dev' OR label BEGINSWITH 'Part of sbu.dev'")).firstMatch
        for _ in 0..<6 where !sbuDev.isHittable {
            app.swipeUp()
        }
        snapshot("02-privacy")
    }
}
