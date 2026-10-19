import XCTest

/// Starts a game, takes a hint, taps the digit it placed, and opens settings, running the
/// accessibility audit on each screen. Runs in Italian.
final class SudokuFlowTests: XCTestCase {
    override func setUp() {
        continueAfterFailure = false
    }

    /// Contrast is left out as in the other apps: colors come from tokens with checked ratios, and
    /// the audit misreads the iOS 26 glass bar. Sheets also leave out the system toolbar buttons.
    private static let screenExclusions: XCUIAccessibilityAuditType = [.contrast]
    private static let sheetExclusions: XCUIAccessibilityAuditType = [.contrast, .dynamicType, .textClipped]

    @MainActor
    private func launch(_ arguments: [String] = []) -> XCUIApplication {
        let app = XCUIApplication()
        app.launchArguments += ["-AppleLanguages", "(it)", "-AppleLocale", "it_IT", "-resetForUITests"] + arguments
        app.launch()
        return app
    }

    @MainActor
    private func audit(_ app: XCUIApplication, excluding excluded: XCUIAccessibilityAuditType = screenExclusions) throws {
        try app.performAccessibilityAudit(for: XCUIAccessibilityAuditType.all.subtracting(excluded)) { issue in
            let label = issue.element?.label ?? ""
            // The cartiglio (Plex Mono relative to caption2, capped by the system), the score sized
            // on the grid (ADR-0015), and the grid's digits, sized by their cell.
            let isFixedSize = label.hasPrefix("SBU · ") || label.hasPrefix("Punteggio") || label.hasPrefix("Riga ")
                || (!label.isEmpty && label.allSatisfy(\.isNumber))
            if [.dynamicType, .textClipped].contains(issue.auditType), isFixedSize {
                return true
            }
            XCTFail("\(issue.compactDescription): \(issue.element?.debugDescription ?? "no element")")
            return true
        }
    }

    @MainActor
    func testHintThenTheSameDigit() throws {
        let app = launch(["-newGame", "easy"])
        let score = app.otherElements["Punteggio 0"]
        XCTAssertTrue(score.waitForExistence(timeout: 5))
        try audit(app)

        let empty = app.buttons.matching(NSPredicate(format: "label BEGINSWITH 'Riga' AND value == 'Vuota'")).firstMatch
        let label = empty.label
        empty.tap()
        app.buttons["Suggerimento"].tap()
        let cell = app.buttons[label]
        XCTAssertFalse(score.exists)
        let digit = try XCTUnwrap((cell.value as? String)?.components(separatedBy: ",").first)

        app.buttons.matching(NSPredicate(format: "label == %@ AND NOT (label BEGINSWITH 'Riga')", digit)).firstMatch.tap()
        XCTAssertTrue(app.staticTexts["Questa cifra non si cambia."].waitForExistence(timeout: 2))

        app.buttons["Nuova partita"].tap()
        app.buttons["Facile"].firstMatch.tap()
        let alert = app.alerts["Iniziare una nuova partita?"]
        XCTAssertTrue(alert.waitForExistence(timeout: 2))
        alert.buttons["Nuova partita"].tap()
        XCTAssertTrue(score.waitForExistence(timeout: 5))
    }

    @MainActor
    func testFirstRunAndSettings() throws {
        let app = launch()
        XCTAssertTrue(app.buttons["Nuova partita"].waitForExistence(timeout: 2))
        try audit(app)

        app.buttons["Impostazioni"].tap()
        XCTAssertTrue(app.staticTexts["Record"].waitForExistence(timeout: 2))
        try audit(app, excluding: Self.sheetExclusions)
    }
}
