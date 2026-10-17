import XCTest

/// Drives the App Store screenshots for `fastlane snapshot`, on the demo camera and codes that
/// `-FASTLANE_SNAPSHOT` opens: the camera, a link checked before it opens, the history, a code
/// made in the creator, then the privacy promise in settings.
final class SnapshotTests: XCTestCase {
    @MainActor
    private func back(_ app: XCUIApplication) {
        app.navigationBars.buttons.element(boundBy: 0).tap()
    }

    @MainActor
    private func tap(_ app: XCUIApplication, _ italian: String, _ english: String) {
        app.buttons.matching(NSPredicate(format: "label == %@ OR label == %@", italian, english)).firstMatch.tap()
    }

    @MainActor
    func testScreenshots() {
        let app = XCUIApplication()
        setupSnapshot(app)
        app.launch()

        let sample = app.buttons.matching(NSPredicate(format: "label == 'Leggi il codice di esempio' OR label == 'Read the sample code'")).firstMatch
        XCTAssertTrue(sample.waitForExistence(timeout: 10))
        snapshot("01-main")

        sample.tap()
        _ = app.staticTexts["sbu.dev"].waitForExistence(timeout: 5)
        sleep(1)
        snapshot("02-result")
        back(app)

        tap(app, "Cronologia", "History")
        sleep(1)
        snapshot("03-history")
        back(app)

        tap(app, "Crea", "Create")
        app.cells.element(boundBy: 0).tap()
        sleep(1)
        snapshot("04-created")
        back(app)
        back(app)

        tap(app, "Impostazioni", "Settings")
        sleep(1)
        // The promises close the settings, under Icona and Suono.
        let sbuDev = app.descendants(matching: .any).matching(NSPredicate(format: "label BEGINSWITH 'Parte di sbu.dev' OR label BEGINSWITH 'Part of sbu.dev'")).firstMatch
        for _ in 0..<6 where !sbuDev.isHittable {
            app.swipeUp()
        }
        snapshot("05-privacy")
    }
}
