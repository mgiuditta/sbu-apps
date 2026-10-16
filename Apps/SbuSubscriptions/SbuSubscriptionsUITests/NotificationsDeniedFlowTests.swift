import XCTest

/// With notifications refused, the add form says so under the reminder, with the way back on.
final class NotificationsDeniedFlowTests: XCTestCase {
    @MainActor
    func testFormWarnsWhenNotificationsAreOff() throws {
        let app = XCUIApplication()
        app.launchArguments += ["-SBU_EMPTY_STORE", "YES", "-SBU_NOTIFICATIONS_DENIED", "YES", "-AppleLanguages", "(it)", "-AppleLocale", "it_IT"]
        app.launch()

        app.buttons["addFirst"].tap()
        app.buttons["addCustom"].tap()
        let warning = app.staticTexts.matching(NSPredicate(format: "label BEGINSWITH %@", "Notifiche disattivate")).firstMatch
        for _ in 0..<4 where !warning.exists { app.swipeUp() }
        XCTAssertTrue(warning.exists, "The warning sits under the reminder")
        XCTAssertTrue(app.buttons["openNotificationSettings"].exists)
        let shot = XCTAttachment(screenshot: app.screenshot())
        shot.name = "notifiche-disattivate"
        shot.lifetime = .keepAlways
        add(shot)
        try app.performAccessibilityAudit(for: XCUIAccessibilityAuditType.all.subtracting([.contrast, .dynamicType])) { issue in
            XCTFail("\(issue.compactDescription): \(issue.element.map { "'\($0.label)' \($0.frame)" } ?? issue.detailedDescription)")
            return true
        }
    }
}
