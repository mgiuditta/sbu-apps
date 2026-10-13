import XCTest

/// Drives the App Store screenshots for `fastlane snapshot`, on the demo library that
/// `-FASTLANE_SNAPSHOT` opens: the space you can free, a card to swipe, the duplicates with the
/// best shot, the bin's final review, then the privacy promise in settings.
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

        app.buttons.element(matching: NSPredicate(format: "label BEGINSWITH 'Scorri' OR label BEGINSWITH 'Swipe'")).firstMatch.tap()
        app.cells.element(boundBy: 1).tap()
        _ = app.descendants(matching: .any).matching(NSPredicate(format: "label BEGINSWITH 'Foto,' OR label BEGINSWITH 'Photo,'")).firstMatch.waitForExistence(timeout: 5)
        sleep(1)
        snapshot("02-swipe")
        back(app)
        back(app)

        app.cells.element(boundBy: 0).tap()
        app.buttons.matching(NSPredicate(format: "label CONTAINS 'gruppi' OR label CONTAINS 'groups'")).firstMatch.tap()
        sleep(1)
        snapshot("03-duplicates")

        app.buttons.matching(NSPredicate(format: "label BEGINSWITH 'Elimina' OR label BEGINSWITH 'Delete'")).firstMatch.tap()
        sleep(1)
        snapshot("04-bin")
        back(app)
        back(app)
        back(app)

        app.navigationBars.buttons.element(boundBy: 0).tap()
        snapshot("05-privacy")
    }
}
