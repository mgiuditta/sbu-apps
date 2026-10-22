import XCTest

/// Drives the App Store screenshots for `fastlane snapshot`.
/// The central figure, the privacy promise in settings, moonrise, moonset and the next phases in
/// Rome, the calendar to pick a day, and the phase alerts with Luna piena on.
final class SnapshotTests: XCTestCase {
    @MainActor
    func testScreenshots() {
        let app = XCUIApplication()
        setupSnapshot(app)
        app.launch()

        snapshot("01-main")

        button("Impostazioni", "Settings", in: app).tap()
        let fullMoon = either(app.switches["Luna piena"], app.switches["Full moon"])
        // A run before may have left it on.
        if fullMoon.value as? String != "1" {
            fullMoon.tap()
            allowNotificationsIfAsked()
        }
        // The Closure stays two seconds, then the alert's time shows.
        let closure = app.descendants(matching: .any).matching(NSPredicate(format: "label BEGINSWITH 'Impostato' OR label BEGINSWITH 'Set'")).firstMatch
        _ = closure.waitForNonExistence(timeout: 5)
        snapshot("05-alerts")

        // The promises close the settings, under Icona and Suono.
        let sbuDev = app.descendants(matching: .any).matching(NSPredicate(format: "label BEGINSWITH 'Parte di sbu.dev' OR label BEGINSWITH 'Part of sbu.dev'")).firstMatch
        for _ in 0..<6 where !sbuDev.isHittable {
            app.swipeUp()
        }
        snapshot("02-privacy")
        button("Fine", "Done", in: app).tap()

        let place = app.buttons["place"]
        XCTAssertTrue(place.waitForExistence(timeout: 5))
        place.tap()
        let search = app.searchFields.firstMatch
        XCTAssertTrue(search.waitForExistence(timeout: 5))
        search.tap()
        search.typeText("Roma")
        app.buttons.matching(NSPredicate(format: "label BEGINSWITH 'Roma' OR label BEGINSWITH 'Rome'")).firstMatch.tap()
        XCTAssertTrue(place.waitForExistence(timeout: 5))
        // Up to the rise and set and the next four phases: the figure goes past the top and the
        // status bar sits over the blank grid between it and the phase name.
        let lower = app.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.75))
        lower.press(forDuration: 0.1, thenDragTo: app.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.283)))
        sleep(1)
        snapshot("03-phases")
        app.swipeDown()

        app.buttons["date"].tap()
        sleep(1)
        snapshot("04-calendar")
    }

    /// iOS asks for notifications the first time on this simulator, over the app: allow them.
    @MainActor
    private func allowNotificationsIfAsked() {
        let alert = XCUIApplication(bundleIdentifier: "com.apple.springboard").alerts.firstMatch
        if alert.waitForExistence(timeout: 3) {
            alert.buttons.element(boundBy: 1).tap()
        }
    }

    @MainActor
    private func button(_ italian: String, _ english: String, in app: XCUIApplication) -> XCUIElement {
        either(app.buttons[italian].firstMatch, app.buttons[english].firstMatch)
    }

    /// The Italian element, or the English one when the run is in English, once either shows up.
    @MainActor
    private func either(_ italian: XCUIElement, _ english: XCUIElement) -> XCUIElement {
        let shown = XCTNSPredicateExpectation(predicate: NSPredicate { _, _ in italian.exists || english.exists }, object: nil)
        _ = XCTWaiter.wait(for: [shown], timeout: 10)
        return italian.exists ? italian : english
    }
}
