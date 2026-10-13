import XCTest

extension XCUIAccessibilityAuditIssue {
    /// A list row half under the screen's edge or a bar, as a scrolled list always has at large
    /// text sizes: the audit reports it as clipped text without naming an element. Text that is
    /// really cut inside a row comes with its element, and still fails.
    var isRowCutByTheScreenEdge: Bool {
        auditType == .textClipped && element == nil
    }
}
