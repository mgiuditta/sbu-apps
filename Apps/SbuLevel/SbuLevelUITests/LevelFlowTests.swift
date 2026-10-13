import XCTest

/// Drives the tool screen, the lock, the two-step calibration and settings, and runs the
/// accessibility audit on each. Runs in Italian with the fixed snapshot tilt (32,4° on the bottom
/// edge), because the simulator has no motion sensor.
final class LevelFlowTests: XCTestCase {
    override func setUp() {
        continueAfterFailure = false
    }

    @MainActor
    private func launch() -> XCUIApplication {
        let app = XCUIApplication()
        app.launchArguments += ["-AppleLanguages", "(it)", "-AppleLocale", "it_IT", "-FASTLANE_SNAPSHOT", "YES"]
        app.launch()
        return app
    }

    /// Contrast is left out everywhere as in the other apps: text colors come from tokens with
    /// checked ratios, and the audit misreads the iOS 26 glass bar. The tool screen also leaves out
    /// element detection: the dial's 0°, 45° and 90° marks are drawn in a Canvas and hidden from
    /// VoiceOver on purpose, because the figure already says the angle.
    private static let toolScreenExclusions: XCUIAccessibilityAuditType = [.contrast, .elementDetection]
    /// Sheets leave out Dynamic Type, as settings do in the other apps, and clipped text: the audit
    /// flags the system Annulla button in the iOS 26 glass toolbar of a medium-height sheet. The
    /// dial shows above a medium-height sheet, so element detection is left out as on the tool screen.
    private static let sheetExclusions: XCUIAccessibilityAuditType = [.contrast, .dynamicType, .textClipped, .elementDetection]

    @MainActor
    private func audit(_ app: XCUIApplication, excluding excluded: XCUIAccessibilityAuditType) throws {
        try app.performAccessibilityAudit(for: XCUIAccessibilityAuditType.all.subtracting(excluded)) { issue in
            XCTFail("\(issue.compactDescription):\(issue.element?.debugDescription ?? "no element")")
            return true
        }
    }

    @MainActor
    func testToolScreenShowsTheEdgeAngleAndPassesTheAccessibilityAudit() throws {
        let app = launch()

        let figure = app.staticTexts.matching(NSPredicate(format: "label BEGINSWITH 'Inclinazione'")).firstMatch
        XCTAssertTrue(figure.waitForExistence(timeout: 5))
        XCTAssertTrue(figure.label.contains("32,4"), figure.label)
        XCTAssertTrue(figure.label.contains("Sul bordo"), figure.label)
        XCTAssertTrue(app.buttons["Calibra"].isEnabled)
        XCTAssertTrue(app.buttons["Blocca"].isEnabled)

        try audit(app, excluding: Self.toolScreenExclusions)
    }

    @MainActor
    func testLockFreezesTheReadingAndSaysSo() throws {
        let app = launch()
        let lock = app.buttons["Blocca"]
        XCTAssertTrue(lock.waitForExistence(timeout: 5))

        lock.tap()

        let figure = app.staticTexts.matching(NSPredicate(format: "label BEGINSWITH 'Inclinazione'")).firstMatch
        XCTAssertTrue(figure.label.contains("Lettura bloccata"), figure.label)
        let unlock = app.buttons["Sblocca"]
        XCTAssertTrue(unlock.exists)
        XCTAssertTrue(unlock.isSelected)
        try audit(app, excluding: Self.toolScreenExclusions)

        unlock.tap()
        XCTAssertTrue(app.buttons["Blocca"].waitForExistence(timeout: 5))
        XCTAssertTrue(figure.label.contains("Sul bordo"), figure.label)
    }

    @MainActor
    func testTwoStepCalibrationThenResetInSettings() throws {
        let app = launch()
        let calibrate = app.buttons["Calibra"]
        XCTAssertTrue(calibrate.waitForExistence(timeout: 5))

        calibrate.tap()

        XCTAssertTrue(app.staticTexts.matching(NSPredicate(format: "label ==[c] 'Passo 1 di 2'")).firstMatch.waitForExistence(timeout: 5))
        XCTAssertTrue(app.staticTexts.matching(NSPredicate(format: "label CONTAINS 'Bordo inferiore'")).firstMatch.exists)
        try audit(app, excluding: Self.sheetExclusions)

        app.buttons["Misura"].tap()
        // A second of steady samples, then the second step.
        let secondStep = app.staticTexts.matching(NSPredicate(format: "label ==[c] 'Passo 2 di 2'")).firstMatch
        XCTAssertTrue(secondStep.waitForExistence(timeout: 5))

        app.buttons["Misura"].tap()
        let done = app.buttons["Fine"]
        XCTAssertTrue(done.waitForExistence(timeout: 5))
        XCTAssertTrue(app.staticTexts["Calibrata"].exists)
        try audit(app, excluding: Self.sheetExclusions)
        done.tap()

        app.buttons["Impostazioni"].tap()
        let reset = app.buttons["Ripristina calibrazione"]
        XCTAssertTrue(reset.waitForExistence(timeout: 5))
        reset.tap()

        // The confirmation names the side: it is reset only after the second tap.
        let side = app.sheets.firstMatch.buttons["Bordo inferiore"]
        XCTAssertTrue(side.waitForExistence(timeout: 5))
        side.tap()
        XCTAssertTrue(reset.waitForNonExistence(timeout: 5))
    }

    @MainActor
    func testSettingsOfferScreenOnAndCalibrationAndPassTheAccessibilityAudit() throws {
        let app = launch()

        app.buttons["Impostazioni"].tap()
        XCTAssertTrue(app.switches["Schermo sempre acceso"].waitForExistence(timeout: 5))
        XCTAssertEqual(app.switches["Schermo sempre acceso"].value as? String, "1")
        XCTAssertTrue(app.buttons["Calibra"].exists)

        // Dynamic Type is left out as in the other apps: in the settings sheet the audit flags
        // every text as partially unsupported, system ones included.
        try audit(app, excluding: [.contrast, .dynamicType])
    }
}
