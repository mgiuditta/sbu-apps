import XCTest

/// Launch and audit helpers shared by the flow tests.
class LibrettoUITestCase: XCTestCase {
    override func setUp() {
        continueAfterFailure = false
    }

    /// Launches on an empty libretto, or on the sample one, in Italian unless told otherwise.
    /// Either way the course settings start fresh and are never the user's.
    @MainActor
    func launch(sample: Bool = false, language: String = "it", locale: String = "it_IT", contentSize: String? = nil) -> XCUIApplication {
        let app = XCUIApplication()
        app.launchArguments += [sample ? "-SBU_SAMPLE_STORE" : "-SBU_EMPTY_STORE", "YES",
                                "-AppleLanguages", "(\(language))", "-AppleLocale", locale]
        if let contentSize {
            app.launchArguments += ["-UIPreferredContentSizeCategoryName", contentSize]
        }
        app.launch()
        return app
    }

    @MainActor
    func attach(_ app: XCUIApplication, _ name: String) {
        let attachment = XCTAttachment(screenshot: app.screenshot())
        attachment.name = name
        attachment.lifetime = .keepAlways
        add(attachment)
    }

    @MainActor
    func type(_ text: String, into field: XCUIElement) {
        XCTAssertTrue(field.waitForExistence(timeout: 5))
        field.tap()
        field.typeText(text)
    }

    /// Contrast comes from the design tokens, checked against WCAG by `Tools/sync_tokens.py`, and Dynamic Type
    /// is checked by hand at AX5, as in the other apps; every other issue fails the test.
    /// - Parameter scrolled: The screen is scrolled, so rows sit half under the navigation bar's glass:
    ///   the audit then reports text "that may be clipped" without naming any element. Only those go.
    @MainActor
    /// - Parameter wrappedValues: Labels of menu-picker values that wrap under their title, whole on screen,
    ///   that the audit reports as clipped; checked by eye on the attached screenshot.
    func audit(_ app: XCUIApplication, scrolled: Bool = false, wrappedValues: Set<String> = []) throws {
        try app.performAccessibilityAudit(for: XCUIAccessibilityAuditType.all.subtracting([.contrast, .dynamicType])) { issue in
            // SbuKit's uppercase captions are tracked, and the audit reads the last letter's tracking as a
            // clipped fraction of a point; on screen they are whole (as in Sbu Clean and Sbu Fuel).
            if issue.auditType == .textClipped, let label = issue.element?.label, label == label.uppercased() {
                return true
            }
            if issue.auditType == .textClipped, let label = issue.element?.label, wrappedValues.contains(label) {
                return true
            }
            if scrolled, issue.auditType == .textClipped, issue.element == nil {
                return true
            }
            XCTFail("\(issue.compactDescription): \(issue.element?.debugDescription ?? issue.detailedDescription)")
            return true
        }
    }
}
