import XCTest

/// Drives the App Store screenshots for `fastlane snapshot` on the drawn still life
/// (`-FASTLANE_SNAPSHOT YES`): the photo with numbered grid, the grid settings, the cell of an
/// A4 sheet, the export, then the privacy promise in settings. Labels are found by symbol or
/// position, so the same test runs in Italian and English.
final class SnapshotTests: XCTestCase {
    @MainActor
    func testScreenshots() {
        let app = XCUIApplication()
        setupSnapshot(app)
        app.launch()

        let done = app.buttons.matching(NSPredicate(format: "label IN %@", ["Fine", "Done"]))
        let pills = app.buttons.matching(NSPredicate(format: "label IN %@", ["Griglia", "Grid"]))
        XCTAssertTrue(pills.firstMatch.waitForExistence(timeout: 5))
        pills.firstMatch.tap()

        let numbers = app.switches.matching(NSPredicate(format: "label IN %@", ["Numeri di righe e colonne", "Row and column numbers"])).firstMatch
        for _ in 0..<6 where !(numbers.exists && numbers.isHittable) {
            app.collectionViews.firstMatch.swipeUp()
        }
        numbers.switches.firstMatch.tap()
        app.collectionViews.firstMatch.swipeDown()
        snapshot("02-grid")
        done.firstMatch.tap()

        XCTAssertTrue(pills.firstMatch.waitForExistence(timeout: 5))
        snapshot("01-main")

        app.buttons.matching(NSPredicate(format: "label IN %@", ["Foglio", "Sheet"])).firstMatch.tap()
        let format = app.buttons.matching(NSPredicate(format: "label BEGINSWITH 'Formato' OR label BEGINSWITH 'Format'")).firstMatch
        XCTAssertTrue(format.waitForExistence(timeout: 5))
        format.tap()
        app.buttons["A4"].tap()
        done.firstMatch.tap()
        XCTAssertTrue(pills.firstMatch.waitForExistence(timeout: 5))
        snapshot("03-sheet")

        app.buttons.matching(NSPredicate(format: "label IN %@", ["Esporta", "Export"])).firstMatch.tap()
        XCTAssertTrue(app.buttons.matching(NSPredicate(format: "label IN %@", ["Salva in Foto", "Save to Photos"])).firstMatch.waitForExistence(timeout: 10))
        snapshot("04-export")
        done.firstMatch.tap()

        XCTAssertTrue(pills.firstMatch.waitForExistence(timeout: 5))
        app.navigationBars.buttons.element(boundBy: 0).tap()
        snapshot("05-privacy")
    }
}
