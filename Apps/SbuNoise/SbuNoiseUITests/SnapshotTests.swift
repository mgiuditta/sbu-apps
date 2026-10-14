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
        snapshot("02-privacy")
    }
}
