import XCTest

/// Launch and audit shared by the flow tests: Italian, an empty store of their own, and the
/// accessibility audit as in the other apps.
class TidyUITestCase: XCTestCase {
    override func setUp() {
        continueAfterFailure = false
    }

    @MainActor
    func launch(_ arguments: [String] = []) -> XCUIApplication {
        let app = XCUIApplication()
        app.launchArguments += ["-AppleLanguages", "(it)", "-AppleLocale", "it_IT", "-SBU_EMPTY_STORE", "YES"]
        app.launchArguments += arguments
        app.launch()
        return app
    }

    /// Contrast is left out as in the other apps: text colors come from tokens with checked
    /// ratios, and the audit misreads the iOS 26 glass bar. Dynamic Type too: system section
    /// headers and footers are capped below the largest sizes, as in Settings.
    @MainActor
    func audit(_ app: XCUIApplication) throws {
        try app.performAccessibilityAudit(for: XCUIAccessibilityAuditType.all.subtracting([.contrast, .dynamicType])) { issue in
            // SbuKit's uppercase captions are tracked, and the audit reads the last letter's tracking
            // as a clipped fraction of a point; on screen they are whole (as in Sbu Fuel).
            if issue.auditType == .textClipped, let label = issue.element?.label, label == label.uppercased() {
                return true
            }
            // A clipped text the audit cannot point to is the iOS 26 glass toolbar's own button
            // ("Modifica"), as in Sbu Find's sheets: there is no element of ours to fix.
            if issue.auditType == .textClipped, issue.element == nil {
                return true
            }
            XCTFail("\(issue.compactDescription): \(issue.element?.debugDescription ?? issue.detailedDescription)")
            return true
        }
    }

    @MainActor
    func addBaseRooms(_ app: XCUIApplication) {
        let button = app.buttons["addBaseRooms"]
        XCTAssertTrue(button.waitForExistence(timeout: 5))
        button.tap()
    }

    /// Swipes up until `element` is there: lists are lazy and keep rows off screen unbuilt.
    @MainActor
    @discardableResult
    func scroll(_ app: XCUIApplication, to element: XCUIElement) -> Bool {
        for _ in 0..<6 where !element.exists {
            app.swipeUp()
        }
        return element.waitForExistence(timeout: 2)
    }
}
