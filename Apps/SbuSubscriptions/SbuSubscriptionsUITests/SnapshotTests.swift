import XCTest

/// Drives the App Store screenshots for `fastlane snapshot`, in Italian and English, on the demo data:
/// the figure and the list, the payments calendar, one subscription, then the privacy promise in settings.
final class SnapshotTests: XCTestCase {
    @MainActor
    func testScreenshots() {
        let app = XCUIApplication()
        setupSnapshot(app)
        app.launch()

        XCTAssertTrue(element("Musica", "Music", in: app).exists)
        snapshot("01-main")

        // The tabs, in order: Abbonamenti, Calendario, Impostazioni.
        let tabs = app.tabBars.buttons
        tabs.element(boundBy: 1).tap()
        XCTAssertTrue(app.buttons.matching(NSPredicate(format: "label BEGINSWITH %@ OR label BEGINSWITH %@", "Oggi", "Today")).firstMatch.waitForExistence(timeout: 5))
        // A day with payments, so the list under the month shows them.
        app.buttons.matching(NSPredicate(format: "label CONTAINS %@ AND NOT (label BEGINSWITH %@) AND NOT (label BEGINSWITH %@)", ": ", "Oggi", "Today")).firstMatch.tap()
        snapshot("02-calendar")
        tabs.element(boundBy: 0).tap()

        app.buttons.matching(NSPredicate(format: "label BEGINSWITH %@ OR label BEGINSWITH %@", "Musica", "Music")).firstMatch.tap()
        XCTAssertTrue(app.buttons["edit"].waitForExistence(timeout: 5))
        snapshot("03-detail")
        // The detail is a sheet: dragged down from its top edge.
        app.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.08))
            .press(forDuration: 0.1, thenDragTo: app.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.98)))
        XCTAssertTrue(app.buttons["edit"].waitForNonExistence(timeout: 5), "The detail sheet closes")

        tabs.element(boundBy: 2).tap()
        XCTAssertTrue(element("Ora dei promemoria", "Reminder time", in: app).exists, "Settings are on screen")
        // The promises close the settings, under Icona and Suono.
        let sbuDev = app.descendants(matching: .any).matching(NSPredicate(format: "label BEGINSWITH 'Parte di sbu.dev' OR label BEGINSWITH 'Part of sbu.dev'")).firstMatch
        for _ in 0..<6 where !sbuDev.isHittable {
            app.swipeUp()
        }
        snapshot("04-privacy")
    }

    /// The Italian element, or the English one when the run is in English, once either shows up.
    @MainActor
    private func element(_ italian: String, _ english: String, in app: XCUIApplication) -> XCUIElement {
        let it = app.descendants(matching: .any)[italian].firstMatch
        let en = app.descendants(matching: .any)[english].firstMatch
        let either = XCTNSPredicateExpectation(predicate: NSPredicate { _, _ in it.exists || en.exists }, object: nil)
        _ = XCTWaiter.wait(for: [either], timeout: 10)
        return it.exists ? it : en
    }
}
