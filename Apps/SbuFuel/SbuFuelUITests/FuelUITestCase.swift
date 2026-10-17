import XCTest

/// Launch and audit helpers shared by the flow tests.
class FuelUITestCase: XCTestCase {
    override func setUp() {
        continueAfterFailure = false
    }

    /// Launches on an empty store, or on the sample car, in Italian unless told otherwise.
    @MainActor
    func launch(sample: Bool = false, language: String = "it", locale: String = "it_IT", contentSize: String? = nil) -> XCUIApplication {
        let app = XCUIApplication()
        app.launchArguments += [sample ? "-SBU_SAMPLE_STORE" : "-SBU_EMPTY_STORE", "YES",
                                "-AppleLanguages", "(\(language))", "-AppleLocale", locale,
                                "-units.consumption", "", "-units.volume", ""]
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
    @MainActor
    func audit(_ app: XCUIApplication, keyboardUp: Bool = false) throws {
        try app.performAccessibilityAudit(for: XCUIAccessibilityAuditType.all.subtracting([.contrast, .dynamicType])) { issue in
            // SbuKit's uppercase captions are tracked, and the audit reads the last letter's tracking as a
            // clipped fraction of a point; on screen they are whole (as in Sbu Clean).
            if issue.auditType == .textClipped, let label = issue.element?.label, label == label.uppercased() {
                return true
            }
            // With the number pad up, the iOS 26.5 audit reports one "potentially inaccessible text" with no
            // element at all, also on the app before v5: the keys, drawn by the keyboard, not by the app.
            if keyboardUp, issue.auditType == .elementDetection, issue.element == nil {
                return true
            }
            XCTFail("\(issue.compactDescription): \(issue.element?.debugDescription ?? issue.detailedDescription)")
            return true
        }
    }
}
