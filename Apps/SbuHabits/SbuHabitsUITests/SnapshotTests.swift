import XCTest

/// Drives the App Store screenshots for `fastlane snapshot`, in Italian and English.
/// First the tool screen with the demo habits, then the privacy promise in settings,
/// reading's Statistiche, its timer running, and last the walking habit's link to Salute.
final class SnapshotTests: XCTestCase {
    @MainActor
    func testScreenshots() {
        let app = XCUIApplication()
        setupSnapshot(app)
        app.launch()

        XCTAssertTrue(element("Leggere", "Read", in: app).exists)
        snapshot("01-main")

        // The gear sits at the bottom of the tool screen, not in the navigation bar.
        button("Impostazioni", "Settings", in: app).tap()
        // The promises close the settings, under Icona and Suono.
        let sbuDev = app.descendants(matching: .any).matching(NSPredicate(format: "label BEGINSWITH 'Parte di sbu.dev' OR label BEGINSWITH 'Part of sbu.dev'")).firstMatch
        for _ in 0..<6 where !sbuDev.isHittable {
            app.swipeUp()
        }
        snapshot("02-privacy")
        button("Fine", "Done", in: app).tap()

        button("Statistiche", "Statistics", in: app).tap()
        button("statistics-Leggere", "statistics-Read", in: app).tap()
        snapshot("04-statistics")
        button("Chiudi", "Close", in: app).tap()

        button("Avvia Leggere", "Start Read", in: app).tap()
        allowNotificationsIfAsked()
        XCTAssertTrue(element("Tempo rimanente", "Time left", in: app).exists)
        snapshot("05-timer")
        button("Annulla", "Cancel", in: app).tap()

        // The settings sheet is still sliding away: wait until the habit's menu can take the tap.
        let walking = button("Opzioni di Camminare", "Options for Walk", in: app)
        let hittable = XCTNSPredicateExpectation(predicate: NSPredicate(format: "isHittable == true"), object: walking)
        XCTAssertEqual(XCTWaiter.wait(for: [hittable], timeout: 5), .completed)
        walking.tap()
        button("Modifica", "Edit", in: app).tap()
        XCTAssertTrue(element("Usa i dati di Salute. Consenti l'accesso se iOS lo chiede.", "Uses data from Health. Allow access if iOS asks.", in: app).exists)
        snapshot("03-health")
    }

    @MainActor
    private func allowNotificationsIfAsked() {
        let alert = XCUIApplication(bundleIdentifier: "com.apple.springboard").alerts.firstMatch
        if alert.waitForExistence(timeout: 2) {
            alert.buttons.element(boundBy: 1).tap()
        }
    }

    /// The Italian element, or the English one when the run is in English, once either shows up.
    @MainActor
    private func element(_ italian: String, _ english: String, in app: XCUIApplication) -> XCUIElement {
        find(app.descendants(matching: .any)[italian].firstMatch, app.descendants(matching: .any)[english].firstMatch)
    }

    @MainActor
    private func button(_ italian: String, _ english: String, in app: XCUIApplication) -> XCUIElement {
        find(app.buttons[italian].firstMatch, app.buttons[english].firstMatch)
    }

    @MainActor
    private func find(_ italian: XCUIElement, _ english: XCUIElement) -> XCUIElement {
        let either = XCTNSPredicateExpectation(predicate: NSPredicate { _, _ in italian.exists || english.exists }, object: nil)
        _ = XCTWaiter.wait(for: [either], timeout: 10)
        return italian.exists ? italian : english
    }
}
