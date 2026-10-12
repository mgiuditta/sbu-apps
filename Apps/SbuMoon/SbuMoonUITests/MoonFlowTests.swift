import XCTest

/// Drives the tool screen like a person would: read the moon, pick or swipe to another day, go back to today.
/// Runs in Italian, so the simulator's language never matters.
final class MoonFlowTests: XCTestCase {
    override func setUp() {
        continueAfterFailure = false
    }

    @MainActor
    private func launch() -> XCUIApplication {
        let app = XCUIApplication()
        app.launchArguments += ["-AppleLanguages", "(it)", "-AppleLocale", "it_IT"]
        app.launch()
        return app
    }

    @MainActor
    private func figure(in app: XCUIApplication) -> XCUIElement {
        app.descendants(matching: .any).matching(NSPredicate(format: "label BEGINSWITH 'Illuminazione'")).firstMatch
    }

    @MainActor
    func testToolScreenShowsTheFigureAndPassesTheAccessibilityAudit() throws {
        let app = launch()

        XCTAssertTrue(figure(in: app).waitForExistence(timeout: 5))
        XCTAssertTrue(figure(in: app).label.contains("%"), figure(in: app).label)
        for phase in ["Luna nuova,", "Primo quarto,", "Luna piena,", "Ultimo quarto,", "Età della luna,", "Distanza dalla Terra,"] {
            XCTAssertTrue(app.descendants(matching: .any).matching(NSPredicate(format: "label BEGINSWITH %@", phase)).firstMatch.exists, phase)
        }
        XCTAssertFalse(app.buttons["today"].exists, "Oggi shows only on another day")

        // Contrast is left out as in Sbu Habits: text colors come from tokens with checked ratios,
        // and the audit misreads the iOS 26 glass bar as text contrast.
        try app.performAccessibilityAudit(for: XCUIAccessibilityAuditType.all.subtracting(.contrast)) { issue in
            XCTFail("\(issue.compactDescription): \(issue.element?.debugDescription ?? "no element")")
            return true
        }
    }

    @MainActor
    func testPickingAnotherDayAndGoingBackToToday() {
        let app = launch()
        let datePill = app.buttons["date"]
        XCTAssertTrue(datePill.waitForExistence(timeout: 5))
        XCTAssertEqual(datePill.label, "Oggi")
        let todayFigure = figure(in: app).label

        datePill.tap()
        let calendar = app.datePickers.firstMatch
        XCTAssertTrue(calendar.waitForExistence(timeout: 5))
        // Another day of this month, at least five days away.
        let day = Calendar.current.component(.day, from: .now) < 15 ? 20 : 5
        calendar.buttons.matching(NSPredicate(format: "label CONTAINS %@", " \(day) ")).firstMatch.tap()
        app.navigationBars.buttons["Fine"].tap()

        let today = app.buttons["today"]
        XCTAssertTrue(today.waitForExistence(timeout: 5))
        XCTAssertNotEqual(datePill.label, "Oggi")

        today.tap()

        XCTAssertFalse(app.buttons["today"].waitForExistence(timeout: 2))
        XCTAssertEqual(figure(in: app).label, todayFigure)
    }

    @MainActor
    func testSwipingChangesTheDayAndBack() {
        let app = launch()
        let datePill = app.buttons["date"]
        XCTAssertTrue(datePill.waitForExistence(timeout: 5))
        let todayFigure = figure(in: app).label

        app.swipeLeft()

        XCTAssertTrue(app.buttons["today"].waitForExistence(timeout: 5), "A swipe to the left shows tomorrow")
        XCTAssertNotEqual(datePill.label, "Oggi")

        app.swipeRight()

        XCTAssertFalse(app.buttons["today"].waitForExistence(timeout: 2), "A swipe to the right comes back to today")
        XCTAssertEqual(datePill.label, "Oggi")
        XCTAssertEqual(figure(in: app).label, todayFigure)
    }
}
