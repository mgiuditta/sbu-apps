import XCTest

/// On the sample car: history, costs and charts, maintenance, a reminder, vehicles and settings, each audited.
final class LogFlowTests: FuelUITestCase {
    @MainActor
    func testEveryScreenOfTheLog() throws {
        let app = launch(sample: true)
        XCTAssertTrue(app.descendants(matching: .any)["figure"].waitForExistence(timeout: 5))
        attach(app, "veicolo")
        try audit(app)

        app.buttons["history"].tap()
        XCTAssertTrue(app.navigationBars["Storico"].waitForExistence(timeout: 5))
        // Each fuel-up that closes a full-to-full stretch shows its consumption.
        XCTAssertTrue(app.buttons.matching(NSPredicate(format: "label CONTAINS %@", "L/100 km")).firstMatch.exists)
        attach(app, "storico")
        try audit(app)
        app.navigationBars.buttons.firstMatch.tap()

        app.buttons["costs"].tap()
        XCTAssertTrue(app.navigationBars["Spese e grafici"].waitForExistence(timeout: 5))
        attach(app, "spese")
        try audit(app)
        app.navigationBars.buttons.firstMatch.tap()

        app.buttons["services"].tap()
        XCTAssertTrue(app.navigationBars["Manutenzione"].waitForExistence(timeout: 5))
        attach(app, "manutenzione")
        try audit(app)
        app.buttons["addReminder"].tap()
        XCTAssertTrue(app.textFields["reminderTitle"].waitForExistence(timeout: 5))
        attach(app, "promemoria")
        try audit(app)
        app.buttons["Annulla"].tap()
        app.buttons["addService"].tap()
        XCTAssertTrue(app.textFields["serviceTitle"].waitForExistence(timeout: 5))
        try audit(app)
        app.buttons["Annulla"].tap()
        app.navigationBars.buttons.firstMatch.tap()

        app.buttons["vehicleMenu"].tap()
        app.buttons["manageVehicles"].tap()
        XCTAssertTrue(app.navigationBars["Veicoli"].waitForExistence(timeout: 5))
        attach(app, "veicoli")
        try audit(app)
        app.buttons["Fine"].tap()

        // Once the sheet is gone.
        XCTAssertTrue(app.navigationBars["Veicoli"].waitForNonExistence(timeout: 5))
        let gear = app.navigationBars.buttons["Impostazioni"]
        XCTAssertTrue(gear.waitForExistence(timeout: 5))
        gear.tap()
        XCTAssertTrue(app.navigationBars["Impostazioni"].waitForExistence(timeout: 5))
        attach(app, "impostazioni")
        try audit(app)
        app.swipeUp()
        XCTAssertTrue(app.buttons["importCSV"].waitForExistence(timeout: 5))
        attach(app, "impostazioni dati")
    }

    @MainActor
    func testDeletingAFuelUpAsksFirst() throws {
        let app = launch(sample: true)
        XCTAssertTrue(app.buttons["history"].waitForExistence(timeout: 5))
        app.buttons["history"].tap()
        let first = app.buttons.matching(NSPredicate(format: "label CONTAINS %@", "km")).firstMatch
        XCTAssertTrue(first.waitForExistence(timeout: 5))
        first.swipeLeft()
        app.buttons["Elimina"].firstMatch.tap()
        XCTAssertTrue(app.staticTexts["Eliminare questa voce?"].waitForExistence(timeout: 5))
        attach(app, "conferma")
    }

    @MainActor
    func testEnglishInTheUnitedStatesShowsMilesPerGallon() throws {
        let app = launch(sample: true, language: "en", locale: "en_US")
        let figure = app.descendants(matching: .any)["figure"]
        XCTAssertTrue(figure.waitForExistence(timeout: 5))
        XCTAssertTrue(figure.label.contains("mpg"), figure.label)
        XCTAssertTrue(app.staticTexts["AVERAGE CONSUMPTION"].exists || figure.label.localizedCaseInsensitiveContains("Average consumption"))
        attach(app, "en_US")
        try audit(app)
    }
}
