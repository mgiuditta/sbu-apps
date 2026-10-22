import XCTest

/// Drives the App Store screenshots for `fastlane snapshot`, on the demo library that
/// `-FASTLANE_SNAPSHOT` opens: the space you can free, a card to swipe, the duplicates with the
/// best shot, the bin's final review, then the privacy promise in settings,
/// which the store shows second.
final class SnapshotTests: XCTestCase {
    @MainActor
    private func back(_ app: XCUIApplication) {
        app.navigationBars.buttons.element(boundBy: 0).tap()
    }

    @MainActor
    func testScreenshots() {
        let app = XCUIApplication()
        setupSnapshot(app)
        app.launch()

        // The home settles once the demo duplicates are found: the first row counts its groups.
        let found = NSPredicate(format: "label CONTAINS '3 gruppi' OR label CONTAINS '3 groups'")
        _ = app.buttons.matching(found).firstMatch.waitForExistence(timeout: 30)
        sleep(1)
        snapshot("01-main")

        // The home is cards on paper, not a list: its rows are found by identifier.
        // Scorri le foto, then Recenti, as the screen tour goes.
        app.descendants(matching: .any)["pill.months"].firstMatch.tap()
        app.descendants(matching: .any)["months.recent"].firstMatch.tap()
        _ = app.descendants(matching: .any).matching(identifier: "swipe.card").firstMatch.waitForExistence(timeout: 5)
        sleep(1)
        snapshot("03-swipe")
        // Back from the deck lands on a home still settling: start it again instead.
        app.terminate()
        app.launch()
        _ = app.buttons.matching(found).firstMatch.waitForExistence(timeout: 30)

        app.descendants(matching: .any)["home.duplicates"].firstMatch.tap()
        app.descendants(matching: .any).matching(NSPredicate(format: "identifier BEGINSWITH 'card.'")).firstMatch.tap()
        sleep(1)
        snapshot("04-duplicates")

        app.descendants(matching: .any)["bottomAction"].firstMatch.tap()
        sleep(1)
        snapshot("05-bin")
        back(app)
        back(app)
        back(app)

        app.buttons.matching(NSPredicate(format: "label == %@ OR label == %@", "Impostazioni", "Settings")).firstMatch.tap()
        // The promises close the settings, under Icona and Suono.
        let sbuDev = app.descendants(matching: .any).matching(NSPredicate(format: "label BEGINSWITH 'Parte di sbu.dev' OR label BEGINSWITH 'Part of sbu.dev'")).firstMatch
        for _ in 0..<6 where !sbuDev.isHittable {
            app.swipeUp()
        }
        snapshot("02-privacy")
    }
}
