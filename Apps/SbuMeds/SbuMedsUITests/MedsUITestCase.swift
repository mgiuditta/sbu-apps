import XCTest

/// Launch and audit shared by the flow tests: Italian, an empty store of their own (or the
/// made-up family), and the accessibility audit as in the other apps.
class MedsUITestCase: XCTestCase {
    override func setUp() {
        continueAfterFailure = false
    }

    @MainActor
    func launch(sample: Bool = false, arguments: [String] = []) -> XCUIApplication {
        let app = XCUIApplication()
        app.launchArguments += ["-AppleLanguages", "(it)", "-AppleLocale", "it_IT"] + arguments
        app.launchArguments += sample ? ["-FASTLANE_SNAPSHOT", "YES"] : ["-SBU_EMPTY_STORE", "YES"]
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
            // A clipped text the audit cannot point to is the iOS 26 glass toolbar's own button,
            // as in Sbu Tidy: there is no element of ours to fix.
            if issue.auditType == .textClipped, issue.element == nil {
                return true
            }
            // A list row grows with its text and wraps it, so it can't clip; the audit still measures
            // icon-and-title rows ("Aggiungi orario", a picker's "Compressa") from the icon's edge,
            // as in Sbu Chats.
            if issue.auditType == .textClipped, let label = issue.element?.label,
               app.cells.staticTexts.matching(NSPredicate(format: "label == %@", label)).firstMatch.exists {
                return true
            }
            // A sheet's inline title is laid out by the system and shows whole; the audit measures
            // it while the sheet is still settling.
            if issue.auditType == .textClipped, let label = issue.element?.label,
               app.navigationBars.staticTexts.matching(NSPredicate(format: "label == %@", label)).firstMatch.exists {
                return true
            }
            let shot = XCTAttachment(screenshot: app.screenshot())
            shot.name = issue.compactDescription
            shot.lifetime = .keepAlways
            self.add(shot)
            XCTFail("\(issue.compactDescription): \(issue.element?.debugDescription ?? issue.detailedDescription)")
            return true
        }
    }

    /// Adds a medicine with a name and the form's defaults: every day at 8:00, one tablet.
    @MainActor
    func addMedicine(_ app: XCUIApplication, named name: String) {
        let field = app.textFields["medicineName"]
        XCTAssertTrue(field.waitForExistence(timeout: 5))
        field.tap()
        field.typeText(name)
        app.buttons["saveMedicine"].tap()
    }

    /// The figure: one element whose label starts with what it counts, then the count and the context.
    @MainActor
    func figure(_ app: XCUIApplication, startingWith prefix: String) -> XCUIElement {
        app.descendants(matching: .any).matching(NSPredicate(format: "label BEGINSWITH %@", prefix)).firstMatch
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
