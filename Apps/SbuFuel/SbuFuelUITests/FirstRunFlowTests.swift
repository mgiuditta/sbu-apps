import XCTest

/// First launch on an empty store: add a vehicle, two full tanks, and the figure appears. Every screen is audited.
final class FirstRunFlowTests: FuelUITestCase {
    @MainActor
    func testTwoFullTanksShowTheAverage() throws {
        let app = launch()

        XCTAssertTrue(app.staticTexts["Aggiungi il tuo veicolo: dal secondo pieno vedi quanto consuma."].waitForExistence(timeout: 5))
        try audit(app)

        app.buttons["addFirstVehicle"].tap()
        XCTAssertTrue(app.textFields["vehicleName"].waitForExistence(timeout: 5))
        try audit(app)
        type("Panda", into: app.textFields["vehicleName"])
        attach(app, "veicolo")
        app.buttons["saveVehicle"].tap()

        XCTAssertTrue(app.staticTexts["Registra un pieno per iniziare."].waitForExistence(timeout: 5))
        try audit(app)

        try addFuelUp(app, odometer: "10000", litres: "40", price: "70", audits: true)
        XCTAssertTrue(app.staticTexts["Fai il prossimo pieno per vedere il consumo."].waitForExistence(timeout: 5))

        try addFuelUp(app, odometer: "10600", litres: "36", price: "64,80")
        // Once per saved fill-up, the Closure says it in one word over the figure.
        XCTAssertTrue(app.descendants(matching: .any)["Registrato"].waitForExistence(timeout: 5))
        // 36 litres over 600 km: 6,0 L/100 km, read with its caption and context as one element.
        let figure = app.descendants(matching: .any).matching(NSPredicate(format: "label CONTAINS %@", "6,0")).firstMatch
        XCTAssertTrue(figure.waitForExistence(timeout: 5), "36 L su 600 km fanno 6,0 L/100 km")
        attach(app, "cifra")
        try audit(app)
    }

    @MainActor
    func testAReadingBelowAnEarlierOneIsNamedAndBlocksSaving() throws {
        let app = launch(sample: true)
        XCTAssertTrue(app.buttons["addFuelUp"].waitForExistence(timeout: 5))
        app.buttons["addFuelUp"].tap()
        let odometer = app.textFields["odometer"]
        XCTAssertTrue(odometer.waitForExistence(timeout: 5))
        odometer.typeText("1000")
        type("30", into: app.textFields["quantity"])
        XCTAssertTrue(app.staticTexts.matching(NSPredicate(format: "label CONTAINS %@", "segnava già")).firstMatch.waitForExistence(timeout: 5))
        XCTAssertFalse(app.buttons["save"].isEnabled)
        attach(app, "conflitto")
    }

    @MainActor
    private func addFuelUp(_ app: XCUIApplication, odometer: String, litres: String, price: String, audits: Bool = false) throws {
        app.buttons["addFuelUp"].tap()
        let field = app.textFields["odometer"]
        XCTAssertTrue(field.waitForExistence(timeout: 5))
        if audits {
            // Once the sheet and the keyboard have settled: mid-animation the title reads as clipped.
            XCTAssertTrue(app.keyboards.firstMatch.waitForExistence(timeout: 5))
            sleep(1)
            attach(app, "modulo")
            try audit(app, keyboardUp: true)
        }
        type(odometer, into: field)
        type(litres, into: app.textFields["quantity"])
        type(price, into: app.textFields["price"])
        attach(app, "rifornimento \(odometer)")
        app.buttons["save"].tap()
    }
}
