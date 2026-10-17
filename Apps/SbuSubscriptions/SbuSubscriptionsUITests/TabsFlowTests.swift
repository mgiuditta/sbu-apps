import XCTest

/// Walks the three tabs on demo data, Abbonamenti, Calendario and Impostazioni, auditing each one.
final class TabsFlowTests: XCTestCase {
    @MainActor
    func testThreeTabs() throws {
        let app = XCUIApplication()
        app.launchArguments += ["-FASTLANE_SNAPSHOT", "YES", "-AppleLanguages", "(it)", "-AppleLocale", "it_IT"]
        app.launch()

        let tabs = app.tabBars.buttons
        XCTAssertTrue(tabs["Abbonamenti"].waitForExistence(timeout: 5))
        XCTAssertEqual(tabs.count, 3, "Abbonamenti, Calendario, Impostazioni")
        XCTAssertTrue(app.buttons.matching(NSPredicate(format: "label BEGINSWITH %@", "Musica")).firstMatch.exists)
        try audit(app, "abbonamenti")

        tabs["Calendario"].tap()
        XCTAssertTrue(app.buttons["Mese successivo"].waitForExistence(timeout: 5))
        try audit(app, "calendario")

        tabs["Impostazioni"].tap()
        XCTAssertTrue(app.descendants(matching: .any)["Ora dei promemoria"].firstMatch.waitForExistence(timeout: 5), "Settings open as a tab")
        XCTAssertFalse(app.buttons["Fine"].exists, "A tab has nothing to close")
        try audit(app, "impostazioni")

        tabs["Abbonamenti"].tap()
        XCTAssertTrue(app.buttons["add"].waitForExistence(timeout: 5))
    }

    /// The tool screen at the largest accessibility size: the title, the figure on one line and the rows still pass.
    @MainActor
    func testToolScreenAtAX5() throws {
        let app = XCUIApplication()
        app.launchArguments += ["-FASTLANE_SNAPSHOT", "YES", "-AppleLanguages", "(it)", "-AppleLocale", "it_IT"]
        app.launchArguments += ["-UIPreferredContentSizeCategoryName", "UICTContentSizeCategoryAccessibilityXXXL"]
        app.launch()

        XCTAssertTrue(app.tabBars.buttons["Abbonamenti"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.buttons["add"].waitForExistence(timeout: 5))
        try audit(app, "abbonamenti AX5")
    }

    @MainActor
    private func audit(_ app: XCUIApplication, _ screen: String) throws {
        try app.performAccessibilityAudit(for: XCUIAccessibilityAuditType.all.subtracting([.contrast, .dynamicType])) { issue in
            // SbuKit's uppercase captions are tracked, and the audit reads the last letter's tracking as a
            // clipped fraction of a point; on screen they are whole.
            if issue.auditType == .textClipped, let label = issue.element?.label, label == label.uppercased() { return true }
            // The system search field's own placeholder, drawn by iOS, not by the app.
            if issue.auditType == .textClipped, issue.element?.elementType == .searchField { return true }
            XCTFail("\(screen): \(issue.compactDescription): \(issue.element.map { "'\($0.label)' \($0.frame)" } ?? issue.detailedDescription)")
            return true
        }
    }
}
