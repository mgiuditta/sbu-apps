import XCTest

/// Drives the App Store screenshots for `fastlane snapshot`, in Italian and English, on the demo data:
/// the figure and the list, the free trial and its reminder, the payments calendar, the privacy promise in
/// settings, then the widget in the Home Screen gallery (the simulator runs in each language: `localize_simulator`).
final class SnapshotTests: XCTestCase {
    @MainActor
    func testScreenshots() {
        let app = XCUIApplication()
        setupSnapshot(app)
        app.launch()

        XCTAssertTrue(element("Musica", "Music", in: app).exists)
        snapshot("01-main")

        // The free trial: when it ends and the reminder before the first payment.
        app.buttons.matching(NSPredicate(format: "label BEGINSWITH %@ OR label BEGINSWITH %@", "Corso di lingue", "Language course")).firstMatch.tap()
        XCTAssertTrue(app.buttons["edit"].waitForExistence(timeout: 5))
        // The trial end and the reminder sit under the payment history.
        let reminder = element("Promemoria", "Reminder", in: app)
        for _ in 0..<4 where !reminder.isHittable {
            app.swipeUp()
        }
        snapshot("02-trial")
        closeSheet(in: app)

        // The tabs, in order: Abbonamenti, Calendario, Impostazioni.
        let tabs = app.tabBars.buttons
        tabs.element(boundBy: 1).tap()
        XCTAssertTrue(app.buttons.matching(NSPredicate(format: "label BEGINSWITH %@ OR label BEGINSWITH %@", "Oggi", "Today")).firstMatch.waitForExistence(timeout: 5))
        // A day with payments, so the list under the month shows them.
        app.buttons.matching(NSPredicate(format: "label CONTAINS %@ AND NOT (label BEGINSWITH %@) AND NOT (label BEGINSWITH %@)", ": ", "Oggi", "Today")).firstMatch.tap()
        snapshot("03-calendar")

        tabs.element(boundBy: 2).tap()
        XCTAssertTrue(element("Ora dei promemoria", "Reminder time", in: app).exists, "Settings are on screen")
        // The promises close the settings, under Icona and Suono.
        let sbuDev = app.descendants(matching: .any).matching(NSPredicate(format: "label BEGINSWITH 'Parte di sbu.dev' OR label BEGINSWITH 'Part of sbu.dev'")).firstMatch
        for _ in 0..<6 where !sbuDev.isHittable {
            app.swipeUp()
        }
        snapshot("05-privacy")

        // The medium widget in the gallery, with its sample data (the same figures as the demo).
        XCUIDevice.shared.press(.home)
        let springboard = XCUIApplication(bundleIdentifier: "com.apple.springboard")
        springboard.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5)).press(forDuration: 1.5)
        let edit = springboard.buttons.matching(NSPredicate(format: "label IN %@", ["Edit", "Modifica"])).firstMatch
        if edit.waitForExistence(timeout: 5) { edit.tap() }
        let addWidget = springboard.buttons.matching(NSPredicate(format: "label IN %@", ["Add Widget", "Aggiungi widget"])).firstMatch
        XCTAssertTrue(addWidget.waitForExistence(timeout: 5))
        addWidget.tap()
        let search = springboard.searchFields.firstMatch
        XCTAssertTrue(search.waitForExistence(timeout: 5))
        search.tap()
        search.typeText("Sbu Subscriptions")
        let result = springboard.descendants(matching: .any).matching(NSPredicate(format: "label CONTAINS %@", "Sbu Subscriptions")).element(boundBy: 1)
        XCTAssertTrue(result.waitForExistence(timeout: 5))
        result.tap()
        sleep(2)
        springboard.swipeLeft()
        // The gallery draws the widget a moment after the page settles.
        sleep(4)
        snapshot("04-widget")
    }

    /// A detail is a sheet: dragged down from its top edge.
    @MainActor
    private func closeSheet(in app: XCUIApplication) {
        app.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.08))
            .press(forDuration: 0.1, thenDragTo: app.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.98)))
        XCTAssertTrue(app.buttons["edit"].waitForNonExistence(timeout: 5), "The detail sheet closes")
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
