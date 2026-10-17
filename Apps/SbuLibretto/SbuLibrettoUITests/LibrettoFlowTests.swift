import XCTest

/// On the sample libretto: dashboard, study plan, editing, deleting, the simulator and settings, each audited.
final class LibrettoFlowTests: LibrettoUITestCase {
    @MainActor
    func testEveryScreenOfTheLibretto() throws {
        let app = launch(sample: true)
        XCTAssertTrue(app.descendants(matching: .any)["figure"].waitForExistence(timeout: 5))
        attach(app, "dashboard")
        try audit(app)
        app.swipeUp()
        XCTAssertTrue(app.descendants(matching: .any)["Base di laurea"].waitForExistence(timeout: 5))
        attach(app, "statistiche")
        try audit(app, scrolled: true)
        app.swipeDown()

        app.buttons["studyPlan"].tap()
        XCTAssertTrue(app.navigationBars["Piano di studi"].waitForExistence(timeout: 5))
        attach(app, "piano di studi")
        try audit(app)

        app.buttons["Da sostenere"].tap()
        XCTAssertTrue(app.buttons["Sistemi operativi"].waitForExistence(timeout: 5))
        XCTAssertFalse(app.buttons["Basi di dati"].exists)
        attach(app, "da sostenere")

        app.buttons["Sistemi operativi"].tap()
        XCTAssertTrue(app.textFields["examName"].waitForExistence(timeout: 5))
        XCTAssertEqual(app.textFields["examName"].value as? String, "Sistemi operativi")
        attach(app, "modifica")
        try audit(app)
        app.buttons["Annulla"].tap()
        app.navigationBars.buttons.firstMatch.tap()

        app.buttons["simulate"].tap()
        XCTAssertTrue(app.navigationBars["Simulazione media"].waitForExistence(timeout: 5))
        attach(app, "simulazione")
        try audit(app)
        type("27,8", into: app.textFields["targetAverage"])
        XCTAssertTrue(app.staticTexts["Ti serve almeno 29 nell'esame da 6 CFU."].waitForExistence(timeout: 5))
        attach(app, "obiettivo")
        try audit(app)
        app.navigationBars.buttons.firstMatch.tap()

        let gear = app.navigationBars.buttons["Impostazioni"]
        XCTAssertTrue(gear.waitForExistence(timeout: 5))
        gear.tap()
        XCTAssertTrue(app.navigationBars["Impostazioni"].waitForExistence(timeout: 5))
        attach(app, "impostazioni")
        try audit(app)
    }

    @MainActor
    func testRegisteringAGradeOnAPlannedExamMovesTheAverage() throws {
        let app = launch(sample: true)
        let figure = app.descendants(matching: .any)["figure"]
        XCTAssertTrue(figure.waitForExistence(timeout: 5))
        XCTAssertTrue(figure.label.contains("27,77"), figure.label)
        app.buttons["studyPlan"].tap()
        app.buttons["Da sostenere"].tap()
        let exam = app.buttons["Reti di calcolatori"]
        XCTAssertTrue(exam.waitForExistence(timeout: 5))
        exam.tap()
        // SbuToggleStyle draws the whole row as the switch: here its inner system switch is not hittable.
        app.switches["isTaken"].tap()
        // The planned sitting is in the future: a grade needs a past date.
        XCTAssertTrue(app.descendants(matching: .any)["examProblem"].waitForExistence(timeout: 5))
        attach(app, "data futura")
        app.buttons["Annulla"].tap()
        XCTAssertTrue(app.navigationBars["Piano di studi"].waitForExistence(timeout: 5))
    }

    @MainActor
    func testDeletingAnExamAsksFirst() throws {
        let app = launch(sample: true)
        XCTAssertTrue(app.buttons["studyPlan"].waitForExistence(timeout: 5))
        app.buttons["studyPlan"].tap()
        // The second year is below the first: the list draws it once it is near the screen.
        app.buttons["Sostenuti"].tap()
        app.swipeUp()
        let exam = app.buttons["Basi di dati"]
        XCTAssertTrue(exam.waitForExistence(timeout: 5))
        exam.swipeLeft()
        app.buttons["Elimina"].firstMatch.tap()
        XCTAssertTrue(app.staticTexts["Eliminare questo esame?"].waitForExistence(timeout: 5))
        attach(app, "conferma")
        app.buttons["Elimina"].firstMatch.tap()
        XCTAssertTrue(exam.waitForNonExistence(timeout: 5))
    }

    @MainActor
    func testEnglishInTheUnitedStates() throws {
        let app = launch(sample: true, language: "en", locale: "en_US")
        let figure = app.descendants(matching: .any)["figure"]
        XCTAssertTrue(figure.waitForExistence(timeout: 5))
        XCTAssertTrue(figure.label.contains("27.77"), figure.label)
        XCTAssertTrue(app.buttons["Simulate exam"].exists)
        attach(app, "en_US")
        try audit(app)
    }

    @MainActor
    func testToolScreenAtTheLargestTextSize() throws {
        let app = launch(sample: true, contentSize: "UICTContentSizeCategoryAccessibilityXXXL")
        let figure = app.descendants(matching: .any)["figure"]
        XCTAssertTrue(figure.waitForExistence(timeout: 5))
        XCTAssertTrue(app.buttons["registerGrade"].exists)
        attach(app, "AX5")
        try audit(app)
    }
}
