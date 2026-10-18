import XCTest

/// Plays a move by tapping, starts a new game and opens settings, running the accessibility
/// audit on each screen. Runs in Italian, from an empty game.
final class SquaresFlowTests: XCTestCase {
    override func setUp() {
        continueAfterFailure = false
    }

    /// Contrast is left out as in the other apps: colors come from tokens with checked ratios, and
    /// the audit misreads the iOS 26 glass bar. Sheets also leave out the system toolbar buttons.
    private static let screenExclusions: XCUIAccessibilityAuditType = [.contrast]
    private static let sheetExclusions: XCUIAccessibilityAuditType = [.contrast, .dynamicType, .textClipped]

    @MainActor
    private func launch() -> XCUIApplication {
        let app = XCUIApplication()
        app.launchArguments += ["-AppleLanguages", "(it)", "-AppleLocale", "it_IT", "-resetForUITests"]
        app.launch()
        return app
    }

    @MainActor
    private func audit(_ app: XCUIApplication, excluding excluded: XCUIAccessibilityAuditType = screenExclusions) throws {
        try app.performAccessibilityAudit(for: XCUIAccessibilityAuditType.all.subtracting(excluded)) { issue in
            let label = issue.element?.label ?? ""
            // The cartiglio (Plex Mono relative to caption2, capped by the system) and the score,
            // sized on the grid by the screen's height, not by text size (ADR-0015).
            let isScore = !label.isEmpty && label.allSatisfy { $0.isNumber || $0 == "." }
            if issue.auditType == .dynamicType, label.hasPrefix("SBU · ") || isScore {
                return true
            }
            if issue.auditType == .textClipped, label.hasPrefix("SBU · ") {
                return true
            }
            XCTFail("\(issue.compactDescription): \(issue.element?.debugDescription ?? "no element")")
            return true
        }
    }

    @MainActor
    func testTapAPieceThenACell() throws {
        let app = launch()
        let score = app.otherElements.matching(NSPredicate(format: "label BEGINSWITH 'Punteggio'")).firstMatch
        XCTAssertTrue(score.waitForExistence(timeout: 5))
        XCTAssertEqual(score.label, "Punteggio 0")
        try audit(app)

        app.buttons.matching(NSPredicate(format: "label BEGINSWITH 'Pezzo da'")).firstMatch.tap()
        // An empty board: the top-left cell fits any piece.
        app.buttons["Riga 1, colonna 1"].tap()
        XCTAssertNotEqual(score.label, "Punteggio 0")

        app.navigationBars.buttons["Nuova partita"].tap()
        let alert = app.alerts["Iniziare una nuova partita?"]
        XCTAssertTrue(alert.waitForExistence(timeout: 2))
        alert.buttons["Nuova partita"].tap()
        XCTAssertEqual(score.label, "Punteggio 0")
    }

    @MainActor
    func testFreeGameAndSettings() throws {
        let app = launch()
        XCTAssertTrue(app.buttons["Nuova partita"].waitForExistence(timeout: 2))
        try audit(app)

        app.buttons["Impostazioni"].tap()
        XCTAssertTrue(app.staticTexts["Record"].waitForExistence(timeout: 2))
        try audit(app, excluding: Self.sheetExclusions)
    }
}
