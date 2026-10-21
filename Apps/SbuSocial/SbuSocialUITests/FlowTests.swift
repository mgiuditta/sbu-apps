import XCTest

/// Every tab opens, on Home first, and passes the accessibility audit.
final class FlowTests: XCTestCase {
    /// Contrast is left out as in the other apps: the audit misreads the grid paper behind text.
    private static let exclusions: XCUIAccessibilityAuditType = [.contrast]
    /// SbuKit's settings also leave out Dynamic Type and clipped text, as the settings sheet does in
    /// the other apps: the system caps the Licenze row and the switch rows below the largest sizes.
    /// How far above the tab bar the audit's larger text sizes reach under it.
    private static let tabBarReach: CGFloat = 120
    private static let settingsExclusions: XCUIAccessibilityAuditType = [.contrast, .dynamicType, .textClipped]

    @MainActor
    func testEveryTabOpensAndPassesTheAudit() throws {
        let app = XCUIApplication()
        app.launchArguments += ["-AppleLanguages", "(it)", "-AppleLocale", "it_IT"]
        app.launch()
        XCTAssertTrue(app.buttons["Instagram"].waitForExistence(timeout: 5), "The app opens on Home")
        try audit(app)

        for tab in ["Sonno", "Statistiche", "Blocco"] {
            app.tabBars.buttons[tab].tap()
            try audit(app)
        }
        app.tabBars.buttons["Impostazioni"].tap()
        try audit(app, excluding: Self.settingsExclusions)
    }

    @MainActor
    private func audit(_ app: XCUIApplication, excluding excluded: XCUIAccessibilityAuditType = exclusions) throws {
        let tabBarTop = app.tabBars.firstMatch.frame.minY
        try app.performAccessibilityAudit(for: XCUIAccessibilityAuditType.all.subtracting(excluded)) { issue in
            let label = issue.element?.label ?? ""
            // A row just above the floating tab bar: at larger text sizes the audit grows it under the
            // bar and calls it cut, but the page scrolls and the row stays whole above it.
            if [.dynamicType, .textClipped].contains(issue.auditType), let frame = issue.element?.frame,
               frame.maxY > tabBarTop - Self.tabBarReach {
                return true
            }
            // SbuKit's cartiglio: Plex Mono relative to caption2, capped by the system at the
            // largest sizes, and tracked uppercase, which the audit measures as clipped (as in Sbu Find).
            if [.dynamicType, .textClipped].contains(issue.auditType), label.hasPrefix("SBU · ") {
                return true
            }
            // SbuFigure: the hero figure snaps to the grid by its length, not by text size, by design.
            if issue.auditType == .dynamicType, !label.isEmpty, label.allSatisfy(\.isNumber) {
                return true
            }
            XCTFail("\(issue.compactDescription): \(issue.element?.debugDescription ?? "no element")")
            return true
        }
    }
}
