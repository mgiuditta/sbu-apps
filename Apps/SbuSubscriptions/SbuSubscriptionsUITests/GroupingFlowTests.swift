import XCTest

/// Groups the home by cycle, folds a section and opens it again; sets a reminder to 10 days in the form.
final class GroupingFlowTests: XCTestCase {
    @MainActor
    func testFoldACycleSectionAndPickReminderDays() throws {
        let app = XCUIApplication()
        app.launchArguments += ["-FASTLANE_SNAPSHOT", "YES", "-AppleLanguages", "(it)", "-AppleLocale", "it_IT"]
        app.launch()

        app.buttons["options"].tap()
        app.buttons["Raggruppa per"].tap()
        app.buttons["Ciclo"].tap()

        let monthly = app.buttons["Mensile"].firstMatch
        XCTAssertTrue(monthly.waitForExistence(timeout: 5))
        let music = app.buttons.matching(NSPredicate(format: "label BEGINSWITH %@", "Musica")).firstMatch
        XCTAssertTrue(music.exists)
        monthly.tap()
        XCTAssertFalse(music.waitForExistence(timeout: 2), "A folded section hides its rows")
        try audit(app)
        monthly.tap()
        XCTAssertTrue(music.waitForExistence(timeout: 5))

        // Put the grouping back, so the other tests find the usual sections.
        app.buttons["options"].tap()
        app.buttons["Raggruppa per"].tap()
        app.buttons["Stato"].tap()

        music.tap()
        app.buttons["edit"].tap()
        let stepper = app.steppers.firstMatch
        for _ in 0..<4 where !stepper.isHittable { app.swipeUp() }
        XCTAssertTrue(app.staticTexts["1 giorno prima"].exists)
        for _ in 0..<9 { stepper.buttons.element(boundBy: 1).tap() }
        XCTAssertTrue(app.staticTexts["10 giorni prima"].exists)
    }

    @MainActor
    func testSortFromTheActiveHeader() throws {
        let app = XCUIApplication()
        app.launchArguments += ["-FASTLANE_SNAPSHOT", "YES", "-AppleLanguages", "(it)", "-AppleLocale", "it_IT"]
        app.launch()

        let sort = app.buttons["sort"]
        for _ in 0..<3 where !sort.exists || !sort.isHittable { app.swipeUp() }
        XCTAssertEqual(sort.value as? String, "Prossimo")
        XCTAssertTrue(app.buttons.matching(NSPredicate(format: "label CONTAINS %@", "Rinnova tra")).firstMatch.exists,
                      "Rows say when they renew")
        sort.tap()
        app.buttons["Nome"].tap()
        XCTAssertEqual(sort.value as? String, "Nome")
        try audit(app)

        // Put the order back, so the other tests find the usual rows.
        sort.tap()
        app.buttons["Prossimo pagamento"].tap()
        XCTAssertEqual(sort.value as? String, "Prossimo")
    }

    @MainActor
    private func audit(_ app: XCUIApplication) throws {
        try app.performAccessibilityAudit(for: XCUIAccessibilityAuditType.all.subtracting([.contrast, .dynamicType])) { issue in
            if issue.auditType == .textClipped, let label = issue.element?.label, label == label.uppercased() { return true }
            // The system search field's own placeholder, drawn by iOS, not by the app.
            if issue.auditType == .textClipped, issue.element?.elementType == .searchField { return true }
            XCTFail("\(issue.compactDescription): \(issue.element.map { "'\($0.label)' \($0.frame)" } ?? issue.detailedDescription)")
            return true
        }
    }
}
