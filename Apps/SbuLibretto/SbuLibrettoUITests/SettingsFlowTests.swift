import XCTest

/// Settings on the sample libretto: the course, the rules of the average and the base, the help; each audited.
final class SettingsFlowTests: LibrettoUITestCase {
    @MainActor
    func openSettings(_ app: XCUIApplication) {
        let gear = app.navigationBars.buttons["Impostazioni"]
        XCTAssertTrue(gear.waitForExistence(timeout: 5))
        gear.tap()
        XCTAssertTrue(app.navigationBars["Impostazioni"].waitForExistence(timeout: 5))
    }

    @MainActor
    func testCumLaudeAtThirtyThreeRaisesTheAverage() throws {
        let app = launch(sample: true)
        let figure = app.descendants(matching: .any)["figure"]
        XCTAssertTrue(figure.waitForExistence(timeout: 5))
        XCTAssertTrue(figure.label.contains("27,77"), figure.label)

        openSettings(app)
        attach(app, "impostazioni")
        try audit(app)
        app.buttons["cumLaudeValue"].tap()
        app.buttons["33"].tap()
        app.buttons["Fine"].tap()

        // One 30 cum laude in 12 CFU: (1833 + 3 × 12) / 66.
        XCTAssertTrue(figure.waitForExistence(timeout: 5))
        XCTAssertTrue(figure.label.contains("28,32"), figure.label)
    }

    @MainActor
    func testRoundingShowsInTheFormulaAndTheBase() throws {
        let app = launch(sample: true)
        openSettings(app)
        app.swipeUp()
        let rounding = app.buttons["rounding"]
        XCTAssertTrue(rounding.waitForExistence(timeout: 5))
        rounding.tap()
        app.buttons["All'intero, 0,50 per eccesso"].tap()
        let formula = app.staticTexts["formula"]
        XCTAssertTrue(formula.waitForExistence(timeout: 5))
        XCTAssertTrue(formula.label.contains("arrotondata all'intero"), formula.label)
        attach(app, "base di laurea")
        // The menu picker's value wraps under its title and is whole on screen (see the attachment), but
        // since the shell's Icona section moved the rows, the audit reads it as clipped: only that text goes.
        try audit(app, scrolled: true, wrappedValues: ["All'intero, 0,50 per eccesso"])

        app.buttons["formulaHelp"].tap()
        XCTAssertTrue(app.navigationBars["Esempi di calcolo"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.staticTexts["Politecnico di Milano"].exists || app.staticTexts["POLITECNICO DI MILANO"].exists)
        attach(app, "esempi")
        try audit(app)
        app.navigationBars["Esempi di calcolo"].buttons.firstMatch.tap()
        let settingsBar = app.navigationBars["Impostazioni"]
        XCTAssertTrue(settingsBar.waitForExistence(timeout: 5))
        settingsBar.buttons["Fine"].tap()

        // 27,77 × 110/30 = 101,83: rounded, 102.
        app.swipeUp()
        let base = app.descendants(matching: .any)["Base di laurea"].firstMatch
        XCTAssertTrue(base.waitForExistence(timeout: 5))
        XCTAssertEqual(base.value as? String, "102")
    }

    @MainActor
    func testExcludingTheWorstGradeAsksHowMany() throws {
        let app = launch(sample: true)
        openSettings(app)
        app.buttons["exclusionKind"].tap()
        app.buttons["Per esami"].tap()
        XCTAssertTrue(app.steppers["excludedExams"].waitForExistence(timeout: 5))
        attach(app, "esclusi")
        try audit(app)
        app.buttons["Fine"].tap()
        // Without the 24 in 6 CFU: (1833 − 144) / 60.
        let figure = app.descendants(matching: .any)["figure"]
        XCTAssertTrue(figure.waitForExistence(timeout: 5))
        XCTAssertTrue(figure.label.contains("28,15"), figure.label)
    }
}
