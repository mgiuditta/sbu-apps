import XCTest

/// Drives the App Store screenshots for `fastlane snapshot` on the demo TV (`-demoTV`, debug
/// builds only, no network): the remote, the touchpad, the TV's apps, the keyboard, then the
/// privacy promise in settings. Labels are matched in Italian and English.
final class SnapshotTests: XCTestCase {
    @MainActor
    func testScreenshots() {
        let app = XCUIApplication()
        setupSnapshot(app)
        app.launchArguments += ["-demoTV", "-navigationMode", "dPad"]
        app.launch()

        let done = app.buttons.matching(NSPredicate(format: "label IN %@", ["Fine", "Done"])).firstMatch
        XCTAssertTrue(app.buttons.matching(NSPredicate(format: "label IN %@", ["OK"])).firstMatch.waitForExistence(timeout: 5))
        snapshot("01-main")

        app.buttons.matching(NSPredicate(format: "label IN %@", ["Touchpad"])).firstMatch.tap()
        snapshot("02-touchpad")
        app.buttons.matching(NSPredicate(format: "label IN %@", ["Frecce", "Arrows"])).firstMatch.tap()

        app.buttons.matching(NSPredicate(format: "label IN %@", ["App", "Apps"])).firstMatch.tap()
        XCTAssertTrue(app.buttons.matching(NSPredicate(format: "label CONTAINS 'YouTube'")).firstMatch.waitForExistence(timeout: 5))
        snapshot("03-apps")
        done.tap()

        app.buttons.matching(NSPredicate(format: "label IN %@", ["Tastiera", "Keyboard"])).firstMatch.tap()
        let field = app.textFields.firstMatch
        XCTAssertTrue(field.waitForExistence(timeout: 5))
        field.typeText("Concerto")
        snapshot("04-keyboard")
        done.tap()

        app.buttons.matching(NSPredicate(format: "label IN %@", ["Impostazioni", "Settings"])).firstMatch.tap()
        snapshot("05-privacy")
    }
}
