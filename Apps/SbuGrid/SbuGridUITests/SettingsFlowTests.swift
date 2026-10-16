import XCTest

/// Drives settings: how to use the grid, the privacy page and the licences, with the audit.
final class SettingsFlowTests: XCTestCase {
    override func setUp() {
        continueAfterFailure = false
    }

    @MainActor
    func testSettingsExplainTheGridAndEndWithThePromise() throws {
        let app = GridFlowTests.launch()
        let gear = app.navigationBars.buttons["Impostazioni"]
        XCTAssertTrue(gear.waitForExistence(timeout: 5))
        gear.tap()

        XCTAssertTrue(app.staticTexts["COME SI USA"].waitForExistence(timeout: 5) || app.staticTexts["Come si usa"].exists)
        XCTAssertTrue(app.staticTexts.matching(NSPredicate(format: "label BEGINSWITH 'Scegli la foto da disegnare'")).firstMatch.exists)
        try GridFlowTests.audit(app, excluding: GridFlowTests.sheetExclusions)

        let licenses = app.buttons["Licenze"]
        GridFlowTests.scroll(app, to: licenses)
        XCTAssertTrue(licenses.isHittable)
        XCTAssertTrue(app.staticTexts.matching(NSPredicate(format: "label BEGINSWITH 'Con Ricalca'")).firstMatch.exists)
        XCTAssertTrue(app.staticTexts.matching(NSPredicate(format: "label BEGINSWITH 'Sbu Grid non disegna al posto tuo'")).firstMatch.exists)
        XCTAssertTrue(app.buttons["Privacy"].exists)
        try GridFlowTests.audit(app, excluding: GridFlowTests.sheetExclusions)

        licenses.tap()
        XCTAssertTrue(app.navigationBars["Licenze"].waitForExistence(timeout: 5))
        app.navigationBars.buttons.firstMatch.tap()
        app.buttons["Fine"].tap()
        XCTAssertTrue(app.buttons["Griglia"].waitForExistence(timeout: 5))
    }
}
