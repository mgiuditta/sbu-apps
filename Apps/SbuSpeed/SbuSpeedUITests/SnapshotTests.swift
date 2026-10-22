import XCTest

/// Drives the App Store screenshots for `fastlane snapshot`, on the fixed drive and the demo trips
/// that `-FASTLANE_SNAPSHOT` shows. The central figure, the privacy promise in settings, the trip
/// log, one trip, then the Parabrezza.
final class SnapshotTests: XCTestCase {
    @MainActor
    func testScreenshots() {
        let app = XCUIApplication()
        setupSnapshot(app)
        app.launch()

        snapshot("01-main")

        button("Impostazioni", "Settings", in: app).tap()
        // The promises close the settings, under Icona and Suono.
        let sbuDev = app.descendants(matching: .any).matching(NSPredicate(format: "label BEGINSWITH 'Parte di sbu.dev' OR label BEGINSWITH 'Part of sbu.dev'")).firstMatch
        for _ in 0..<6 where !sbuDev.isHittable {
            app.swipeUp()
        }
        snapshot("02-privacy")
        button("Fine", "Done", in: app).tap()

        button("Viaggi", "Trips", in: app).tap()
        let trip = app.buttons.matching(identifier: "trip").firstMatch
        XCTAssertTrue(trip.waitForExistence(timeout: 5))
        snapshot("03-trips")
        trip.tap()
        sleep(1)
        snapshot("04-trip")
        app.navigationBars.buttons.firstMatch.tap()
        app.navigationBars.buttons.firstMatch.tap()

        button("Parabrezza", "HUD", in: app).tap()
        sleep(1)
        snapshot("05-hud")
    }

    /// The Italian button, or the English one when the run is in English, once either shows up.
    @MainActor
    private func button(_ italian: String, _ english: String, in app: XCUIApplication) -> XCUIElement {
        let it = app.buttons[italian].firstMatch
        let en = app.buttons[english].firstMatch
        let shown = XCTNSPredicateExpectation(predicate: NSPredicate { _, _ in it.exists || en.exists }, object: nil)
        _ = XCTWaiter.wait(for: [shown], timeout: 10)
        return it.exists ? it : en
    }
}
