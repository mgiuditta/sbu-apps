import XCTest

extension XCUIApplication {
    /// Runs the accessibility audit and fails with every issue's element, except the system's
    /// own chrome: navigation bar items keep their size and show in the Large Content Viewer.
    @MainActor
    func auditAccessibility(file: StaticString = #filePath, line: UInt = #line) throws {
        var issues: [String] = []
        let bar = navigationBars.firstMatch
        try performAccessibilityAudit(for: XCUIAccessibilityAuditType.all.subtracting(.contrast)) { issue in
            if issue.auditType == .dynamicType, let element = issue.element, bar.exists, bar.frame.contains(element.frame) {
                return true
            }
            issues.append("\(issue.compactDescription): \(issue.element?.label ?? "no element") \(issue.element?.frame ?? .zero)")
            return true
        }
        XCTAssertTrue(issues.isEmpty, issues.joined(separator: "\n"), file: file, line: line)
    }
}
