import XCTest

/// Drives the tool screen, the lock, the two-step calibration and settings, and runs the
/// accessibility audit on each. Runs in Italian with the fixed snapshot tilt (32,4° on the bottom
/// edge), because the simulator has no motion sensor.
final class LevelFlowTests: XCTestCase {
    override func setUp() {
        continueAfterFailure = false
    }

    @MainActor
    private func launch(gravity: String = "") -> XCUIApplication {
        let app = XCUIApplication()
        app.launchArguments += ["-AppleLanguages", "(it)", "-AppleLocale", "it_IT", "-FASTLANE_SNAPSHOT", "YES", "-FIXED_GRAVITY", gravity]
        // Every test starts uncalibrated: a string where the calibration data goes reads as none.
        app.launchArguments += ["-calibration", "none"]
        // And in degrees to the tenth, whatever an earlier test chose: arguments win over saved settings.
        app.launchArguments += ["-unit", "degrees", "-locksWhenSteady", "NO", "-speech", "off", "-playsSound", "NO", "-locksWithVolumeButton", "NO", "-dialTurn", "0"]
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

    /// Scrolls settings up until `element` is on screen: the calibration rows sit below the fold.
    @MainActor
    private func scroll(_ app: XCUIApplication, to element: XCUIElement) -> Bool {
        _ = app.collectionViews.firstMatch.waitForExistence(timeout: 5)
        for _ in 0..<5 where element.isHittable == false {
            app.collectionViews.firstMatch.swipeUp()
        }
        return element.isHittable
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
    func testZeroHereReadsRelativeUntilAbsolute() throws {
        let app = launch()
        let zero = app.buttons["Azzera qui"]
        XCTAssertTrue(zero.waitForExistence(timeout: 5))

        zero.tap()

        let figure = app.staticTexts.matching(NSPredicate(format: "label BEGINSWITH 'Inclinazione'")).firstMatch
        XCTAssertTrue(figure.label.contains("0,0 gradi"), figure.label)
        XCTAssertTrue(figure.label.contains("Relativo"), figure.label)
        let absolute = app.buttons["Assoluto"]
        XCTAssertTrue(absolute.isSelected)
        try audit(app, excluding: Self.toolScreenExclusions)

        absolute.tap()
        XCTAssertTrue(app.buttons["Azzera qui"].waitForExistence(timeout: 5))
        XCTAssertTrue(figure.label.contains("32,4"), figure.label)
    }

    /// The simulator has no camera: the sight says so, still reads the line of sight, and closes again.
    @MainActor
    func testTheSightMeasuresTheLineOfSightAndSaysWhenThereIsNoCamera() throws {
        let app = launch()
        let sight = app.buttons["Mirino"]
        XCTAssertTrue(sight.waitForExistence(timeout: 5))

        sight.tap()

        let figure = app.staticTexts.matching(NSPredicate(format: "label BEGINSWITH 'Linea di mira'")).firstMatch
        XCTAssertTrue(figure.waitForExistence(timeout: 5))
        XCTAssertTrue(figure.label.contains("Fotocamera non disponibile"), figure.label)
        XCTAssertTrue(sight.isSelected)
        XCTAssertFalse(app.buttons["Calibra"].exists)
        try audit(app, excluding: Self.toolScreenExclusions)

        sight.tap()
        XCTAssertTrue(app.staticTexts.matching(NSPredicate(format: "label BEGINSWITH 'Inclinazione'")).firstMatch.waitForExistence(timeout: 5))
        XCTAssertTrue(app.buttons["Calibra"].exists)
    }

    @MainActor
    func testTheSteadyLockWaitsForAStillReadingThenLocks() throws {
        let app = launch()
        app.buttons["Impostazioni"].tap()
        let steady = app.switches["Blocca a lettura stabile"]
        XCTAssertTrue(steady.waitForExistence(timeout: 5))
        steady.switches.firstMatch.tap()
        XCTAssertTrue(app.sliders["Tolleranza"].waitForExistence(timeout: 5))
        app.buttons["Fine"].tap()

        app.buttons["Blocca"].tap()

        // The fixed tilt is perfectly still: two seconds, then the lock.
        XCTAssertTrue(app.buttons["In attesa"].waitForExistence(timeout: 2))
        XCTAssertTrue(app.buttons["Sblocca"].waitForExistence(timeout: 5))
        let figure = app.staticTexts.matching(NSPredicate(format: "label BEGINSWITH 'Inclinazione'")).firstMatch
        XCTAssertTrue(figure.label.contains("Lettura bloccata"), figure.label)
        XCTAssertTrue(figure.label.contains("32,4"), figure.label)
    }

    @MainActor
    func testTurningTheDialReads0AtTheSides() throws {
        let app = launch()
        let dial = app.otherElements["Quadrante"]
        XCTAssertTrue(dial.waitForExistence(timeout: 5))

        // A quarter turn by hand, from the top of the dial round to its right side.
        let top = dial.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.1))
        let right = dial.coordinate(withNormalizedOffset: CGVector(dx: 0.9, dy: 0.5))
        top.press(forDuration: 0.1, thenDragTo: right)

        let figure = app.staticTexts.matching(NSPredicate(format: "label BEGINSWITH 'Inclinazione'")).firstMatch
        XCTAssertTrue(figure.label.contains("57,6"), figure.label)
        XCTAssertEqual(dial.value as? String, "0° sui lati")
        try audit(app, excluding: Self.toolScreenExclusions)

        right.press(forDuration: 0.1, thenDragTo: top)
        XCTAssertTrue(figure.label.contains("32,4"), figure.label)
        XCTAssertEqual(dial.value as? String, "0° sui bordi in alto e in basso")
    }

    @MainActor
    func testFlatShowsTheBubbleAndItsAxesWithoutTheDial() throws {
        let app = launch(gravity: "flat")
        let figure = app.staticTexts.matching(NSPredicate(format: "label BEGINSWITH 'Inclinazione'")).firstMatch
        XCTAssertTrue(figure.waitForExistence(timeout: 5))

        XCTAssertTrue(figure.label.contains("In piano"), figure.label)
        // The dial is hidden from VoiceOver when flat, but XCUITest still lists SwiftUI's hidden
        // elements, so only the axes are checked here.
        XCTAssertTrue(app.otherElements.matching(NSPredicate(format: "label BEGINSWITH 'Asse orizzontale'")).firstMatch.exists)
        try audit(app, excluding: Self.toolScreenExclusions)
    }

    @MainActor
    func testATapOnTheDialHidesBarsAndPillsAndAnotherShowsThem() throws {
        let app = launch()
        let dial = app.otherElements["Quadrante"]
        XCTAssertTrue(dial.waitForExistence(timeout: 5))

        dial.tap()

        XCTAssertTrue(app.buttons["Blocca"].waitForNonExistence(timeout: 5))
        XCTAssertFalse(app.buttons["Impostazioni"].exists)
        XCTAssertTrue(app.staticTexts.matching(NSPredicate(format: "label BEGINSWITH 'Inclinazione'")).firstMatch.exists)
        try audit(app, excluding: Self.toolScreenExclusions)

        dial.tap()
        XCTAssertTrue(app.buttons["Blocca"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.buttons["Impostazioni"].exists)
    }

    @MainActor
    func testTwoStepCalibrationThenResetInSettings() throws {
        // 0,6° off on the bottom edge: within what a calibration accepts.
        let app = launch(gravity: "nearlyLevel")
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
        XCTAssertTrue(scroll(app, to: reset))
        reset.tap()

        // The confirmation names the side: it is reset only after the second tap.
        let side = app.sheets.firstMatch.buttons["Bordo inferiore"]
        XCTAssertTrue(side.waitForExistence(timeout: 5))
        side.tap()
        XCTAssertTrue(reset.waitForNonExistence(timeout: 5))
    }

    /// The screenshot tilt is 32,4°: as a sensor error it is impossible, so nothing is saved.
    @MainActor
    func testAnImplausibleCalibrationIsRefusedAndStartsOver() {
        let app = launch()
        app.buttons["Calibra"].tap()
        let measure = app.buttons["Misura"]
        XCTAssertTrue(measure.waitForExistence(timeout: 5))

        measure.tap()
        let secondStep = app.staticTexts.matching(NSPredicate(format: "label ==[c] 'Passo 2 di 2'")).firstMatch
        XCTAssertTrue(secondStep.waitForExistence(timeout: 5))
        measure.tap()

        let notice = app.staticTexts["La superficie è troppo inclinata o l'iPhone si è mosso. Riprova su una superficie stabile."]
        XCTAssertTrue(notice.waitForExistence(timeout: 5))
        XCTAssertTrue(app.staticTexts.matching(NSPredicate(format: "label ==[c] 'Passo 1 di 2'")).firstMatch.exists)
        XCTAssertTrue(app.buttons["Annulla"].exists)
        XCTAssertFalse(app.buttons["Fine"].exists)
    }

    @MainActor
    func testSettingsOfferScreenOnAndCalibrationAndPassTheAccessibilityAudit() throws {
        let app = launch()

        app.buttons["Impostazioni"].tap()
        XCTAssertTrue(app.switches["Schermo sempre acceso"].waitForExistence(timeout: 5))
        XCTAssertEqual(app.switches["Schermo sempre acceso"].value as? String, "1")
        XCTAssertTrue(app.buttons["Calibra"].exists)
        XCTAssertTrue(app.buttons.matching(NSPredicate(format: "label BEGINSWITH 'Leggi ad alta voce'")).firstMatch.exists)
        XCTAssertTrue(app.switches["Blocca a lettura stabile"].exists)
        XCTAssertTrue(app.switches["Suono alla misura"].exists)
        XCTAssertTrue(app.switches["Blocca col tasto volume nel mirino"].exists)

        // Dynamic Type is left out as in the other apps: in the settings sheet the audit flags
        // every text as partially unsupported, system ones included.
        try audit(app, excluding: [.contrast, .dynamicType])
    }

    @MainActor
    func testTheUnitChosenInSettingsReadsTheFigure() throws {
        let app = launch()
        app.buttons["Impostazioni"].tap()
        let units = app.buttons.matching(NSPredicate(format: "label BEGINSWITH 'Unità di misura'")).firstMatch
        XCTAssertTrue(units.waitForExistence(timeout: 5))
        units.tap()
        let percent = app.buttons["Pendenza in %"]
        XCTAssertTrue(percent.waitForExistence(timeout: 5))

        percent.tap()
        app.buttons["Fine"].tap()

        // 32,4° is a 63,5 % slope; VoiceOver says the unit in words.
        let figure = app.staticTexts.matching(NSPredicate(format: "label BEGINSWITH 'Inclinazione'")).firstMatch
        XCTAssertTrue(figure.waitForExistence(timeout: 5))
        XCTAssertTrue(figure.label.contains("63,5 per cento"), figure.label)
        try audit(app, excluding: Self.toolScreenExclusions)
    }

    @MainActor
    func testCalibraInSettingsOpensTheCalibration() {
        let app = launch(gravity: "nearlyLevel")
        app.buttons["Impostazioni"].tap()
        let row = app.collectionViews.buttons["Calibra"]
        XCTAssertTrue(scroll(app, to: row))

        row.tap()

        let firstStep = app.staticTexts.matching(NSPredicate(format: "label ==[c] 'Passo 1 di 2'")).firstMatch
        XCTAssertTrue(firstStep.waitForExistence(timeout: 5))
        app.buttons["Annulla"].tap()
        XCTAssertTrue(firstStep.waitForNonExistence(timeout: 5))
        XCTAssertTrue(app.switches["Schermo sempre acceso"].exists)
    }
}
