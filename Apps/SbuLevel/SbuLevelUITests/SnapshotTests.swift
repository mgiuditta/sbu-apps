import XCTest

/// Drives the App Store screenshots for `fastlane snapshot`.
/// The edge angle, the privacy promise in settings, the same angle as a slope in %, the surface
/// lying flat, and a locked reading. The Sight needs a camera: its screenshot comes from an iPhone.
final class SnapshotTests: XCTestCase {
    @MainActor
    func testScreenshots() {
        let app = launch()
        snapshot("01-main")

        button("Impostazioni", "Settings", in: app).tap()
        // The promises close the settings, under Icona and Suono.
        let sbuDev = app.descendants(matching: .any).matching(NSPredicate(format: "label BEGINSWITH 'Parte di sbu.dev' OR label BEGINSWITH 'Part of sbu.dev'")).firstMatch
        for _ in 0..<6 where !sbuDev.isHittable {
            app.swipeUp()
        }
        snapshot("02-privacy")
        app.terminate()

        _ = launch(unit: "percent")
        snapshot("03-slope")
        app.terminate()

        _ = launch(gravity: "flat")
        snapshot("04-flat")
        app.terminate()

        let locking = launch()
        button("Blocca", "Lock", in: locking).tap()
        sleep(1)
        snapshot("05-lock")
    }

    /// The sensor as it comes, whatever an earlier run calibrated or chose.
    @MainActor
    private func launch(unit: String = "degrees", gravity: String? = nil) -> XCUIApplication {
        let app = XCUIApplication()
        setupSnapshot(app)
        app.launchArguments += ["-calibration", "none", "-unit", unit, "-dialTurn", "0", "-locksWhenSteady", "NO"]
        if let gravity {
            app.launchArguments += ["-FIXED_GRAVITY", gravity]
        }
        app.launch()
        sleep(1)
        return app
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
