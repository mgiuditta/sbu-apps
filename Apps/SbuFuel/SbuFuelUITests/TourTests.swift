import XCTest

/// Walks every screen of the sample car and keeps a screenshot of each, for the precision pass.
/// Text size and language come from the environment (TEST_RUNNER_SBU_SIZE, TEST_RUNNER_SBU_LANGUAGE);
/// light or dark from the simulator. It asserts only that each screen opens.
final class TourTests: FuelUITestCase {
    @MainActor
    func testTour() throws {
        let environment = ProcessInfo.processInfo.environment
        let english = environment["SBU_LANGUAGE"] == "en"
        let app = XCUIApplication()
        app.launchArguments += ["-SBU_SAMPLE_STORE", "YES",
                                "-AppleLanguages", english ? "(en)" : "(it)", "-AppleLocale", english ? "en_US" : "it_IT",
                                "-units.consumption", "", "-units.volume", ""]
        app.launchEnvironment["SBU_IMPORT_FIXTURE"] = "date,odometer,gallons,price,partial_fuelup\n2026-10-01,48100,9.5,3.299,0\n2026-10-12,48420,10.1,3.199,1\n2026-10-12,48420,10.1,3.199,1\n"
        if let size = environment["SBU_SIZE"] {
            app.launchArguments += ["-UIPreferredContentSizeCategoryName", size]
        }
        app.launch()

        XCTAssertTrue(app.descendants(matching: .any)["figure"].waitForExistence(timeout: 10))
        attach(app, "01 veicolo")
        app.swipeUp()
        attach(app, "02 veicolo in fondo")
        app.swipeDown()

        open("history", in: app)
        attach(app, "03 storico")
        app.buttons.matching(NSPredicate(format: "label CONTAINS %@ OR label CONTAINS %@", "km", "mpg")).element(boundBy: 1).tap()
        sleep(1)
        attach(app, "04 modifica rifornimento")
        app.swipeUp()
        attach(app, "05 modifica rifornimento in fondo")
        app.buttons.matching(NSPredicate(format: "label IN %@", ["Annulla", "Cancel"])).firstMatch.tap()
        back(app)

        open("costs", in: app)
        attach(app, "06 spese")
        app.swipeUp()
        attach(app, "07 grafici")
        app.swipeUp()
        attach(app, "08 grafici in fondo")
        back(app)

        open("services", in: app)
        attach(app, "09 manutenzione")
        reveal(app.buttons["addReminder"], in: app).tap()
        sleep(1)
        attach(app, "10 promemoria")
        app.buttons.matching(NSPredicate(format: "label IN %@", ["Annulla", "Cancel"])).firstMatch.tap()
        reveal(app.buttons["addService"], in: app).tap()
        sleep(1)
        attach(app, "11 intervento")
        app.buttons.matching(NSPredicate(format: "label IN %@", ["Annulla", "Cancel"])).firstMatch.tap()
        back(app)

        app.buttons["addFuelUp"].tap()
        sleep(1)
        attach(app, "12 nuovo rifornimento")
        app.buttons.matching(NSPredicate(format: "label IN %@", ["Annulla", "Cancel"])).firstMatch.tap()

        app.buttons["vehicleMenu"].tap()
        sleep(1)
        attach(app, "13 menu veicoli")
        app.buttons["manageVehicles"].tap()
        sleep(1)
        attach(app, "14 veicoli")
        app.buttons.matching(NSPredicate(format: "label CONTAINS %@", english ? "Petrol" : "Benzina")).firstMatch.tap()
        sleep(1)
        attach(app, "15 veicolo modifica")
        app.swipeUp()
        attach(app, "16 veicolo modifica in fondo")
        app.navigationBars.matching(NSPredicate(format: "identifier IN %@", ["Veicolo", "Vehicle"])).firstMatch.buttons.firstMatch.tap()
        sleep(1)
        app.buttons.matching(NSPredicate(format: "label IN %@", ["Fine", "Done"])).firstMatch.tap()
        sleep(1)

        app.navigationBars.buttons.matching(NSPredicate(format: "label IN %@", ["Impostazioni", "Settings"])).firstMatch.tap()
        sleep(1)
        attach(app, "17 impostazioni")
        app.swipeUp()
        attach(app, "18 impostazioni in fondo")
        let importButton = reveal(app.buttons["importCSV"], in: app)
        if importButton.waitForExistence(timeout: 3) {
            importButton.tap()
            sleep(1)
            attach(app, "19 importa")
            app.swipeUp()
            attach(app, "20 importa anteprima")
        }
    }

    /// Scrolls until the element can be tapped, for the accessibility sizes where it starts off screen.
    @MainActor
    @discardableResult
    private func reveal(_ element: XCUIElement, in app: XCUIApplication) -> XCUIElement {
        for _ in 0..<8 where !(element.exists && element.isHittable) {
            app.swipeUp()
        }
        return element
    }

    /// Taps a row of the tool screen, scrolling it clear of the bar and of the bottom button first.
    @MainActor
    private func open(_ identifier: String, in app: XCUIApplication) {
        let link = app.buttons[identifier]
        let bottom = app.buttons["addFuelUp"].frame.minY
        for _ in 0..<6 where link.frame.maxY > bottom - 8 || link.frame.minY < 140 {
            let up = link.frame.maxY > bottom - 8
            app.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: up ? 0.55 : 0.4))
                .press(forDuration: 0.05, thenDragTo: app.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: up ? 0.4 : 0.55)))
        }
        link.tap()
        sleep(1)
    }

    @MainActor
    private func back(_ app: XCUIApplication) {
        app.navigationBars.buttons.firstMatch.tap()
        sleep(1)
    }
}
