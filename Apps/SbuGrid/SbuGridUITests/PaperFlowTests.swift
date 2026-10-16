import XCTest

/// Drives the sheet, the crop and the export on the drawn still life, with the audit on each.
final class PaperFlowTests: XCTestCase {
    override func setUp() {
        continueAfterFailure = false
    }

    @MainActor
    private func chooseA4(_ app: XCUIApplication) {
        XCTAssertTrue(app.buttons["Foglio"].waitForExistence(timeout: 5))
        app.buttons["Foglio"].tap()
        let format = app.buttons.matching(NSPredicate(format: "label BEGINSWITH 'Formato'")).firstMatch
        XCTAssertTrue(format.waitForExistence(timeout: 5))
        format.tap()
        app.buttons["A4"].tap()
    }

    @MainActor
    func testWithoutASheetTheSheetScreenSaysHowItWorks() throws {
        let app = GridFlowTests.launch()
        XCTAssertTrue(app.buttons["Foglio"].waitForExistence(timeout: 5))
        app.buttons["Foglio"].tap()
        XCTAssertTrue(app.staticTexts["Senza foglio ritagli la foto come vuoi e scegli righe e colonne in Griglia."].waitForExistence(timeout: 5))
        XCTAssertFalse(app.buttons.matching(NSPredicate(format: "label BEGINSWITH 'Unità'")).firstMatch.exists)
        try GridFlowTests.audit(app, excluding: GridFlowTests.sheetExclusions)
    }

    @MainActor
    func testAnA4SheetMakesTheCellTheFigure() throws {
        let app = GridFlowTests.launch()
        chooseA4(app)

        XCTAssertTrue(app.staticTexts["21 × 29,7 cm"].waitForExistence(timeout: 5))
        let side = app.steppers["Lato della cella"]
        GridFlowTests.scroll(app, to: side)
        XCTAssertEqual(side.value as? String, "2 centimetri")
        try GridFlowTests.audit(app, excluding: GridFlowTests.sheetExclusions)

        side.buttons.element(boundBy: 1).tap()
        XCTAssertEqual(side.value as? String, "2,5 centimetri")
        app.buttons["Fine"].tap()

        // 2.5 cm on A4: 9 columns, 12 rows.
        XCTAssertTrue(GridFlowTests.figure(app, "2,5 centimetri").waitForExistence(timeout: 5))
        XCTAssertTrue(GridFlowTests.figure(app, "A4 verticale, 9 × 12 celle").exists)
        try GridFlowTests.audit(app)

        // The grid settings say where the rows and columns come from.
        app.buttons["Griglia"].tap()
        let columns = app.steppers["Colonne"]
        GridFlowTests.scroll(app, to: app.switches["Celle quadrate"])
        XCTAssertFalse(columns.isEnabled)
        XCTAssertEqual(columns.value as? String, "9")
    }

    @MainActor
    func testTheCropMovesAndIsAppliedOrCancelled() throws {
        let app = GridFlowTests.launch()
        chooseA4(app)
        let crop = app.buttons["Ritaglia la foto"]
        GridFlowTests.scroll(app, to: crop)
        crop.tap()

        let frame = app.otherElements["Ritaglio"]
        XCTAssertTrue(frame.waitForExistence(timeout: 5))
        XCTAssertTrue(app.buttons["Annulla"].exists)
        XCTAssertTrue(app.buttons["Ritaglia"].exists)
        // The whole frame, handles included, is on screen and above the home indicator.
        XCTAssertGreaterThan(frame.frame.minY, app.navigationBars.firstMatch.frame.maxY)
        XCTAssertLessThan(frame.frame.maxY, app.frame.maxY - 60)
        // The crop has the same system toolbar as a sheet, and the same exclusions.
        try GridFlowTests.audit(app, excluding: GridFlowTests.sheetExclusions)

        app.buttons["Annulla"].tap()
        XCTAssertTrue(app.buttons["Ritaglia la foto"].waitForExistence(timeout: 5))
        app.buttons["Ritaglia la foto"].tap()
        XCTAssertTrue(frame.waitForExistence(timeout: 5))
        app.buttons["Ritaglia"].tap()
        XCTAssertTrue(app.buttons["Fine"].waitForExistence(timeout: 5))
        app.buttons["Fine"].tap()
        XCTAssertTrue(GridFlowTests.figure(app, "2 centimetri").waitForExistence(timeout: 5))
    }

    @MainActor
    func testExportOffersPhotosAndSharingAndThePDFOnlyWithASheet() throws {
        let app = GridFlowTests.launch()
        XCTAssertTrue(app.buttons["Esporta"].waitForExistence(timeout: 5))
        app.buttons["Esporta"].tap()

        XCTAssertTrue(app.buttons["Salva in Foto"].waitForExistence(timeout: 10))
        XCTAssertTrue(app.buttons["Condividi l'immagine"].exists)
        XCTAssertTrue(app.staticTexts["1200 × 1600 pixel, come la foto."].exists)
        XCTAssertTrue(app.staticTexts["Per un PDF in scala scegli un formato in Foglio."].exists)
        XCTAssertFalse(app.buttons["Condividi il PDF in scala"].exists)
        try GridFlowTests.audit(app, excluding: GridFlowTests.sheetExclusions)
        app.buttons["Fine"].tap()

        chooseA4(app)
        app.buttons["Fine"].tap()
        app.buttons["Esporta"].tap()
        let pdf = app.buttons["Condividi il PDF in scala"]
        XCTAssertTrue(pdf.waitForExistence(timeout: 10))
        XCTAssertTrue(app.staticTexts.matching(NSPredicate(format: "label BEGINSWITH 'Un foglio di 21 × 29,7 cm'")).firstMatch.exists)
        try GridFlowTests.audit(app, excluding: GridFlowTests.sheetExclusions)
    }
}
