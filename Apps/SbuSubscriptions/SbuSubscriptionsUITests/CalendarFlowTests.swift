import XCTest

/// Opens the calendar on demo data, moves a month, and adds from a long-pressed day, auditing each screen.
final class CalendarFlowTests: XCTestCase {
    @MainActor
    func testCalendar() throws {
        let app = XCUIApplication()
        app.launchArguments += ["-FASTLANE_SNAPSHOT", "YES", "-AppleLanguages", "(it)", "-AppleLocale", "it_IT"]
        app.launch()

        app.buttons["calendar"].tap()
        XCTAssertTrue(app.buttons["Mese successivo"].waitForExistence(timeout: 5))
        attach(app, "calendario")
        try audit(app)

        app.buttons["Mese successivo"].tap()
        attach(app, "mese-successivo")
        app.buttons["Mese precedente"].tap()

        let today = app.buttons.matching(NSPredicate(format: "label BEGINSWITH %@", "Oggi")).firstMatch
        XCTAssertTrue(today.exists, "Today's cell says so to VoiceOver")
        today.press(forDuration: 1)
        app.buttons["Aggiungi da questo giorno"].tap()
        XCTAssertTrue(app.searchFields.firstMatch.waitForExistence(timeout: 5), "The add sheet opens")
    }

    @MainActor
    private func attach(_ app: XCUIApplication, _ name: String) {
        let attachment = XCTAttachment(screenshot: app.screenshot())
        attachment.name = name
        attachment.lifetime = .keepAlways
        add(attachment)
    }

    @MainActor
    private func audit(_ app: XCUIApplication) throws {
        try app.performAccessibilityAudit(for: XCUIAccessibilityAuditType.all.subtracting([.contrast, .dynamicType])) { issue in
            XCTFail("\(issue.compactDescription): \(issue.element.map { "'\($0.label)' \($0.frame)" } ?? issue.detailedDescription)")
            return true
        }
    }
}
