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

        // On the figure: the pills under the moon are buttons, and a test swipe is fast enough to tap them.
        figure(in: app).swipeLeft()

        XCTAssertTrue(app.buttons["today"].waitForExistence(timeout: 5), "A swipe to the left shows tomorrow")
        XCTAssertNotEqual(datePill.label, "Oggi")

        figure(in: app).swipeRight()

        XCTAssertFalse(app.buttons["today"].waitForExistence(timeout: 2), "A swipe to the right comes back to today")
        XCTAssertEqual(datePill.label, "Oggi")
        XCTAssertEqual(figure(in: app).label, todayFigure)
    }

    @MainActor
    func testChoosingACityShowsMoonriseAndMoonset() throws {
        let app = launch()
        let place = app.buttons["place"]
        XCTAssertTrue(place.waitForExistence(timeout: 5))

        place.tap()
        let search = app.searchFields.firstMatch
        XCTAssertTrue(search.waitForExistence(timeout: 5))
        XCTAssertTrue(app.buttons["useCurrentLocation"].exists)
        try audit(app, inSheet: true)

        search.tap()
        search.typeText("Oslo")
        app.buttons["Oslo"].firstMatch.tap()

        XCTAssertTrue(place.waitForExistence(timeout: 5))
        XCTAssertTrue(place.label.contains("Oslo"), place.label)
        let riseOrSet = app.descendants(matching: .any)
            .matching(NSPredicate(format: "label BEGINSWITH 'Sorge,' OR label BEGINSWITH 'Tramonta,' OR label BEGINSWITH 'Sorgere e tramonto,'"))
            .firstMatch
        XCTAssertTrue(riseOrSet.waitForExistence(timeout: 5))
        try audit(app)
    }

    @MainActor
    func testPhaseAlertsInSettings() throws {
        let app = launch()
        app.buttons["Impostazioni"].tap()

        let fullMoon = app.switches["Luna piena"]
        XCTAssertTrue(fullMoon.waitForExistence(timeout: 5))
        for phase in ["Luna nuova", "Primo quarto", "Ultimo quarto"] {
            XCTAssertTrue(app.switches[phase].exists, phase)
        }
        // Earlier runs, or the person on their own iPhone, may have left some on: the time row
        // shows while any is.
        for phase in ["Luna piena", "Luna nuova", "Primo quarto", "Ultimo quarto"] where app.switches[phase].value as? String == "1" {
            app.switches[phase].switches.firstMatch.tap()
        }

        fullMoon.switches.firstMatch.tap()
        allowNotificationsIfAsked()

        XCTAssertTrue(app.datePickers["Ora dell'avviso"].waitForExistence(timeout: 5) || app.staticTexts["Ora dell'avviso"].exists)
        try audit(app, inSheet: true)

        fullMoon.switches.firstMatch.tap()
        XCTAssertFalse(app.staticTexts["Ora dell'avviso"].waitForExistence(timeout: 2))
    }

    /// iOS asks for notifications the first time on this simulator, over the app: allow them.
    @MainActor
    private func allowNotificationsIfAsked() {
        let alert = XCUIApplication(bundleIdentifier: "com.apple.springboard").alerts.firstMatch
        if alert.waitForExistence(timeout: 3) {
            alert.buttons.element(boundBy: 1).tap()
        }
    }

    @MainActor
    /// Contrast is left out as on the tool screen. In a sheet Dynamic Type too, as in Sbu Habits and
    /// Sbu Speed: there the audit flags every text as partially unsupported, system ones included.
    private func audit(_ app: XCUIApplication, inSheet: Bool = false) throws {
        let types = XCUIAccessibilityAuditType.all.subtracting(inSheet ? [.contrast, .dynamicType] : [.contrast])
        try app.performAccessibilityAudit(for: types) { issue in
            // The system's own bar button: SwiftUI gives it no Dynamic Type, as in Sbu Habits.
            if issue.auditType == .dynamicType, issue.element?.label == "Fine" {
                return true
            }
            // The system search field's placeholder, at the audit's largest text sizes.
            if issue.auditType == .textClipped, issue.element?.elementType == .searchField {
                return true
            }
            XCTFail("\(issue.compactDescription): \(issue.element?.debugDescription ?? "no element")")
            return true
        }
    }
}
