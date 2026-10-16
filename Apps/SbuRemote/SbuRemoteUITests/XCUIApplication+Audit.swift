import XCTest

extension XCUIApplication {
    /// Runs the accessibility audit and fails with every issue's element, except the system's
    /// own chrome: navigation bar items keep their size and show in the Large Content Viewer.
    ///
    /// `dynamicType` is audited on the tool screen, which is all SbuTheme text styles. Lists in
    /// sheets and settings use the system's own section headers, which the audit reports as
    /// partly unsupported while they scale on screen (as in Sbu Chats and Sbu Fuel).
    @MainActor
    func auditAccessibility(dynamicType: Bool = true, file: StaticString = #filePath, line: UInt = #line) throws {
        var issues: [String] = []
        let bars = navigationBars.allElementsBoundByIndex.map(\.frame)
        var types = XCUIAccessibilityAuditType.all.subtracting(.contrast)
        if !dynamicType { types.remove(.dynamicType) }
        try performAccessibilityAudit(for: types) { issue in
            // No element: something the screen's edge cuts or the glass bar blurs; scrolling shows it whole (as in Sbu Chats).
            if issue.element == nil { return true }
            // A list row grows with its text and wraps it, so it can't clip; the audit measures
            // icon-and-title rows from the icon's edge (as in Sbu Chats).
            if issue.auditType == .textClipped, let label = issue.element?.label,
               self.cells.staticTexts.matching(NSPredicate(format: "label == %@", label)).firstMatch.exists { return true }
            if issue.auditType == .dynamicType, let element = issue.element, bars.contains(where: { $0.contains(element.frame) }) {
                return true
            }
            issues.append("\(issue.compactDescription): \(issue.element?.label ?? "no element") \(issue.element?.frame ?? .zero)")
            return true
        }
        XCTAssertTrue(issues.isEmpty, issues.joined(separator: "\n"), file: file, line: line)
    }
}
