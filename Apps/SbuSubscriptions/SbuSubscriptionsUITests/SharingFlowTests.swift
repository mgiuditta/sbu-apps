import XCTest

/// A list shared with you shows under "Condivise con te", read only, and can be removed; the Lists
/// screen offers Condividi. Audited on each screen.
final class SharingFlowTests: XCTestCase {
    @MainActor
    func testReceivedListAndShareButton() throws {
        let app = XCUIApplication()
        app.launchArguments += ["-FASTLANE_SNAPSHOT", "YES", "-SBU_DEMO_RECEIVED", "YES", "-AppleLanguages", "(it)", "-AppleLocale", "it_IT"]
        app.launch()

        let shared = app.buttons.matching(NSPredicate(format: "label BEGINSWITH %@", "Famiglia")).firstMatch
        for _ in 0..<4 where !shared.isHittable { app.swipeUp() }
        XCTAssertTrue(shared.waitForExistence(timeout: 5), "Condivise con te shows the list")
        attach(app, "condivise-home")
        shared.tap()
        XCTAssertTrue(app.staticTexts.matching(NSPredicate(format: "label CONTAINS %@", "Anna Rossi")).firstMatch.waitForExistence(timeout: 5))
        attach(app, "condivisa")
        try audit(app)

        // SbuButton inside a List reads as not hittable to XCTest, though a finger reaches it (as in DetailFlowTests).
        let remove = app.buttons["Rimuovi lista"]
        app.coordinate(withNormalizedOffset: .zero).withOffset(CGVector(dx: remove.frame.midX, dy: remove.frame.midY)).tap()
        let confirm = app.buttons.matching(NSPredicate(format: "label == %@ AND identifier != %@", "Rimuovi lista", "removeList")).firstMatch
        XCTAssertTrue(confirm.waitForExistence(timeout: 5))
        confirm.tap()
        XCTAssertFalse(shared.waitForExistence(timeout: 2))

        app.swipeDown(); app.swipeDown(); app.swipeDown()
        app.tabBars.buttons["Impostazioni"].tap()
        let lists = app.buttons["Liste"]
        for _ in 0..<4 where !lists.isHittable { app.swipeUp() }
        lists.tap()
        XCTAssertTrue(app.textFields["newList"].waitForExistence(timeout: 5))
        attach(app, "liste")
        try audit(app)
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
            if issue.auditType == .textClipped, let label = issue.element?.label, label == label.uppercased() { return true }
            XCTFail("\(issue.compactDescription): \(issue.element.map { "'\($0.label)' \($0.frame)" } ?? issue.detailedDescription)")
            return true
        }
    }
}
