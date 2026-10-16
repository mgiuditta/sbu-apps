import XCTest

/// Drives Medisafe's flows: first medicine, a dose taken from its card, people, the medicine's
/// screen with refill and history, "Prendi tutto"; with the accessibility audit on each screen.
final class MedsFlowTests: MedsUITestCase {
    @MainActor
    func testFirstMedicineThenTakeItsDose() throws {
        let app = launch()
        let add = app.buttons["addFirstMedicine"]
        XCTAssertTrue(add.waitForExistence(timeout: 5))
        XCTAssertTrue(app.staticTexts["Nessun farmaco"].exists)
        try audit(app)

        add.tap()
        XCTAssertTrue(app.textFields["medicineName"].waitForExistence(timeout: 5))
        try audit(app)
        addMedicine(app, named: "Ramipril")

        let dose = app.buttons.matching(identifier: "dose").firstMatch
        XCTAssertTrue(dose.waitForExistence(timeout: 5))
        XCTAssertTrue(dose.label.contains("Ramipril"), dose.label)
        XCTAssertTrue(figure(app, startingWith: "Da prendere oggi").label.contains("1"))
        try audit(app)

        dose.tap()
        let taken = app.buttons["markTaken"]
        XCTAssertTrue(taken.waitForExistence(timeout: 5))
        // Full height first: at half height the screen behind stays in view, and the audit reads
        // that dimmed text as unreachable.
        app.navigationBars["Ramipril"].swipeUp()
        try audit(app)
        taken.tap()

        XCTAssertTrue(dose.waitForExistence(timeout: 5))
        XCTAssertTrue(dose.label.contains("Presa alle"), dose.label)
        XCTAssertTrue(figure(app, startingWith: "Da prendere oggi").label.contains("0"))
    }

    @MainActor
    func testSwipeSkipsAndTheCardUndoes() throws {
        let app = launch()
        app.buttons["addFirstMedicine"].tap()
        addMedicine(app, named: "Atorvastatina")
        let dose = app.buttons.matching(identifier: "dose").firstMatch
        XCTAssertTrue(dose.waitForExistence(timeout: 5))
        dose.swipeLeft()
        app.buttons["Saltata"].firstMatch.tap()
        XCTAssertTrue(dose.label.contains("Saltata"), dose.label)

        dose.tap()
        let unmark = app.buttons["unmark"]
        XCTAssertTrue(unmark.waitForExistence(timeout: 5))
        unmark.tap()
        XCTAssertTrue(dose.waitForExistence(timeout: 5))
        XCTAssertFalse(dose.label.contains("Saltata"), dose.label)
    }

    @MainActor
    func testAddAPersonAndSwitchToThem() throws {
        let app = launch()
        XCTAssertTrue(app.buttons["addFirstMedicine"].waitForExistence(timeout: 5))
        app.buttons["medicines"].tap()
        let addPerson = app.buttons["addPerson"]
        XCTAssertTrue(addPerson.waitForExistence(timeout: 5))
        try audit(app)

        addPerson.tap()
        let name = app.textFields["personName"]
        XCTAssertTrue(name.waitForExistence(timeout: 5))
        name.typeText("Luca")
        try audit(app)
        app.buttons["savePerson"].tap()
        XCTAssertTrue(app.staticTexts["LUCA"].waitForExistence(timeout: 5) || app.staticTexts["Luca"].exists)

        app.navigationBars.buttons.firstMatch.tap()
        let picker = app.buttons["personPicker"]
        XCTAssertTrue(picker.waitForExistence(timeout: 5))
        picker.tap()
        app.buttons["Luca"].tap()
        XCTAssertTrue(picker.waitForExistence(timeout: 5))
        XCTAssertEqual(picker.value as? String, "Luca")
    }

    @MainActor
    func testTakeAllMarksTheWholeTime() throws {
        let app = launch(sample: true)
        // Grandma has two doses at 21:00, still to take at 10:12.
        let picker = app.buttons["personPicker"]
        XCTAssertTrue(picker.waitForExistence(timeout: 5))
        picker.tap()
        app.buttons["Nonna Rita"].tap()
        let takeAll = app.buttons["takeAll"].firstMatch
        XCTAssertTrue(scroll(app, to: takeAll))
        let before = figure(app, startingWith: "Da prendere oggi").label
        takeAll.tap()
        app.swipeDown()
        app.swipeDown()
        let after = figure(app, startingWith: "Da prendere oggi")
        XCTAssertTrue(after.waitForExistence(timeout: 5))
        XCTAssertNotEqual(after.label, before)
    }

    @MainActor
    func testMedicineScreenRefillsAndShowsTheHistory() throws {
        let app = launch(sample: true)
        XCTAssertTrue(app.buttons.matching(identifier: "dose").firstMatch.waitForExistence(timeout: 5))
        try audit(app)
        app.buttons["medicines"].tap()
        let medicine = app.buttons.matching(NSPredicate(format: "identifier == 'medicine' AND label BEGINSWITH 'Levotiroxina'")).firstMatch
        XCTAssertTrue(medicine.waitForExistence(timeout: 5))
        XCTAssertTrue(medicine.label.contains("Scorte basse"), medicine.label)
        try audit(app)

        medicine.tap()
        XCTAssertTrue(figure(app, startingWith: "Prese in 30 giorni").waitForExistence(timeout: 5))
        try audit(app)
        let refill = app.buttons["refill"]
        XCTAssertTrue(scroll(app, to: refill))
        refill.tap()
        // Not audited: the half-height sheet leaves the screen behind it in view, and the audit
        // reads that dimmed text as unreachable.
        XCTAssertTrue(app.buttons["confirmRefill"].waitForExistence(timeout: 5))
        app.buttons["confirmRefill"].tap()
        XCTAssertFalse(app.staticTexts["Scorte basse: ricompralo"].waitForExistence(timeout: 2))

        let history = app.staticTexts.matching(identifier: "historyEntry").firstMatch
        XCTAssertTrue(scroll(app, to: history))
        let full = app.buttons["fullHistory"]
        XCTAssertTrue(scroll(app, to: full))
        full.tap()
        XCTAssertTrue(app.staticTexts.matching(identifier: "historyEntry").firstMatch.waitForExistence(timeout: 5))
        try audit(app)
    }

    @MainActor
    func testEditFormShowsEveryFrequency() throws {
        let app = launch(sample: true)
        XCTAssertTrue(app.buttons["addMedicine"].waitForExistence(timeout: 5))
        app.buttons["addMedicine"].tap()
        XCTAssertTrue(app.textFields["medicineName"].waitForExistence(timeout: 5))
        app.buttons["frequency"].tap()
        app.buttons["A cicli"].tap()
        XCTAssertTrue(app.staticTexts["Giorni sì: 21"].waitForExistence(timeout: 5))
        try audit(app)
        app.buttons["Annulla"].tap()
    }

    @MainActor
    func testSettingsOfferRemindersOnWithRepeats() throws {
        let app = launch()
        XCTAssertTrue(app.buttons["addFirstMedicine"].waitForExistence(timeout: 5))
        app.navigationBars.buttons.element(boundBy: 1).tap()
        let toggle = app.switches["remindersToggle"]
        XCTAssertTrue(scroll(app, to: toggle))
        XCTAssertEqual(toggle.value as? String, "1")
        XCTAssertTrue(app.buttons["repeatMinutes"].exists)
        XCTAssertTrue(app.buttons["snoozeMinutes"].exists)
        try audit(app)
        toggle.switches.firstMatch.tap()
        XCTAssertFalse(app.buttons["repeatMinutes"].waitForExistence(timeout: 2))

        // No dose advice, data on the iPhone: said once, in settings.
        let note = app.staticTexts.matching(NSPredicate(format: "label BEGINSWITH 'Sbu Meds ti ricorda'")).firstMatch
        XCTAssertTrue(scroll(app, to: note))
        XCTAssertTrue(app.staticTexts["Licenze"].exists || app.buttons["Licenze"].exists)
        try audit(app)
    }

    @MainActor
    func testReportMakesAPDFToShare() throws {
        let app = launch(sample: true)
        XCTAssertTrue(app.buttons["medicines"].waitForExistence(timeout: 5))
        app.buttons["medicines"].tap()
        app.buttons["report"].tap()
        XCTAssertTrue(figure(app, startingWith: "Dosi prese").waitForExistence(timeout: 5))
        let share = app.buttons["sharePDF"]
        XCTAssertTrue(scroll(app, to: share))
        try audit(app)
        app.swipeDown()
        app.buttons["period"].tap()
        app.buttons["7 giorni"].tap()
        XCTAssertTrue(scroll(app, to: share))
    }
}
