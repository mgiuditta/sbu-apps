import XCTest

/// From an empty libretto: the first grade, a planned exam, wrong credits, and the sample libretto.
final class FirstRunFlowTests: LibrettoUITestCase {
    @MainActor
    func testTheFirstGradeBecomesTheAverage() throws {
        let app = launch()
        let first = app.buttons["addFirstExam"]
        XCTAssertTrue(first.waitForExistence(timeout: 5))
        attach(app, "vuoto")
        try audit(app)

        first.tap()
        XCTAssertTrue(app.textFields["examName"].waitForExistence(timeout: 5))
        // Name first, focused: the keyboard is already up.
        app.textFields["examName"].typeText("Analisi I")
        type("9", into: app.textFields["credits"])
        attach(app, "nuovo voto")
        try audit(app)
        app.buttons["saveExam"].tap()

        let figure = app.descendants(matching: .any)["figure"]
        XCTAssertTrue(figure.waitForExistence(timeout: 5))
        // The default grade is 30: the average is 30,00 and the base 110.
        XCTAssertTrue(figure.label.contains("30,00"), figure.label)
        XCTAssertTrue(app.staticTexts["Dal primo voto"].exists)
        XCTAssertEqual(app.descendants(matching: .any)["Base di laurea"].firstMatch.value as? String, "110")
        attach(app, "primo voto")
        try audit(app)
    }

    @MainActor
    func testWrongCreditsSayWhyAndCannotBeSaved() throws {
        let app = launch()
        app.buttons["addFirstExam"].tap()
        XCTAssertTrue(app.textFields["examName"].waitForExistence(timeout: 5))
        app.textFields["examName"].typeText("Tesi")
        let save = app.buttons["saveExam"]
        XCTAssertFalse(save.isEnabled)

        type("0", into: app.textFields["credits"])
        XCTAssertTrue(app.descendants(matching: .any)["examProblem"].waitForExistence(timeout: 5))
        XCTAssertFalse(save.isEnabled)
        attach(app, "CFU a zero")

        app.textFields["credits"].typeText(",5")
        XCTAssertTrue(app.descendants(matching: .any)["examProblem"].waitForNonExistence(timeout: 5))
        XCTAssertTrue(save.isEnabled)
    }

    @MainActor
    func testAPlannedExamIsNotInTheAverage() throws {
        let app = launch()
        app.buttons["addFirstExam"].tap()
        XCTAssertTrue(app.textFields["examName"].waitForExistence(timeout: 5))
        app.textFields["examName"].typeText("Fisica")
        type("6", into: app.textFields["credits"])
        app.switches["isTaken"].switches.firstMatch.tap()
        XCTAssertFalse(app.buttons["grade"].exists)
        XCTAssertTrue(app.switches["hasDate"].waitForExistence(timeout: 5))
        attach(app, "da sostenere")
        try audit(app)
        app.buttons["saveExam"].tap()

        let figure = app.descendants(matching: .any)["figure"]
        XCTAssertTrue(figure.waitForExistence(timeout: 5))
        XCTAssertTrue(app.staticTexts["Registra il primo voto per vedere la media."].exists)
        XCTAssertFalse(app.descendants(matching: .any)["Base di laurea"].exists)
    }

    @MainActor
    func testTheSampleLibrettoFillsTheDashboard() throws {
        let app = launch()
        let sample = app.buttons["addSample"]
        XCTAssertTrue(sample.waitForExistence(timeout: 5))
        sample.tap()
        let figure = app.descendants(matching: .any)["figure"]
        XCTAssertTrue(figure.waitForExistence(timeout: 5))
        XCTAssertTrue(figure.label.contains("27,77"), figure.label)
        let credits = app.descendants(matching: .any)["credits"]
        XCTAssertTrue((credits.value as? String ?? "").contains("69 / 180"), credits.debugDescription)
    }
}
