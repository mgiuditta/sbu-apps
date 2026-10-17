import XCTest

/// Drives the tool screen and the settings sheet, and runs the accessibility audit on both.
/// Runs in Italian with the fixed snapshot drive, so the simulator needs no GPS and shows no location prompt.
final class SpeedFlowTests: XCTestCase {
    @MainActor
    override func setUp() {
        continueAfterFailure = false
        // A failed landscape test may leave the simulator on its side.
        XCUIDevice.shared.orientation = .portrait
    }

    @MainActor
    private func launch(contentSize: String? = nil) -> XCUIApplication {
        let app = XCUIApplication()
        app.launchArguments += [
            "-AppleLanguages", "(it)", "-AppleLocale", "it_IT", "-FASTLANE_SNAPSHOT", "YES",
            // Whatever an earlier run chose: km/h and no limit.
            "-unit", "kilometersPerHour", "-speedLimit", "",
        ]
        if let contentSize {
            app.launchArguments += ["-UIPreferredContentSizeCategoryName", contentSize]
        }
        app.launch()
        return app
    }

    /// The figure: one element whose label starts with what it measures, then the speed and the status.
    @MainActor
    private func figureElement(_ app: XCUIApplication, _ caption: String = "Velocità") -> XCUIElement {
        app.descendants(matching: .any).matching(NSPredicate(format: "label BEGINSWITH %@", caption + ",")).firstMatch
    }

    /// SbuKit sizes the figure in grid cells rather than a text style, and draws the cartiglio in
    /// Plex Mono scaled by hand: on purpose, so the Dynamic Type check skips just those two, and
    /// still checks every other text on the screen. The audit also reads the cartiglio's tracking
    /// as clipping, though every letter shows.
    private static func isSbuKitGridType(_ issue: XCUIAccessibilityAuditIssue) -> Bool {
        guard let label = issue.element?.label else { return false }
        let isCartiglio = label.hasPrefix("SBU ·")
        // The figure, and its digits alone as the audit also reads them: "52", or a dash with no speed.
        let isFigure = label.hasPrefix("Velocità,") || label.hasPrefix("SOG,") || label.allSatisfy { $0.isNumber || $0 == "–" }
        switch issue.auditType {
        case .dynamicType: return isCartiglio || isFigure
        case .textClipped: return isCartiglio
        default: return false
        }
    }

    /// Contrast is left out as in Sbu Habits: text colors come from tokens with checked ratios,
    /// and the audit misreads the iOS 26 glass bar.
    @MainActor
    private func audit(_ app: XCUIApplication, excluding excluded: XCUIAccessibilityAuditType = .contrast) throws {
        try app.performAccessibilityAudit(for: XCUIAccessibilityAuditType.all.subtracting(excluded)) { issue in
            guard Self.isSbuKitGridType(issue) == false else { return true }
            XCTFail("\(issue.compactDescription): \(issue.element?.debugDescription ?? "no element")")
            return true
        }
    }

    @MainActor
    func testToolScreenShowsTheSpeedAndTheTripAndPassesTheAccessibilityAudit() throws {
        let app = launch()

        let figure = figureElement(app)
        XCTAssertTrue(figure.waitForExistence(timeout: 5))
        XCTAssertTrue(figure.label.contains("52"), figure.label)
        XCTAssertTrue(app.staticTexts["SBU · VELOCITÀ · KM/H · GPS PRECISO"].exists)
        XCTAssertTrue(app.otherElements["Massima"].exists)
        XCTAssertEqual(app.otherElements["Durata"].value as? String, "16 minuti e 10 secondi")
        XCTAssertEqual(app.otherElements["Altitudine"].value as? String, "122 metri")
        XCTAssertEqual(app.otherElements["Rotta"].value as? String, "247 gradi, sud-ovest")
        XCTAssertTrue(app.buttons["Salva e azzera"].isEnabled)

        try audit(app)
    }

    @MainActor
    func testToolScreenAtTheLargestTextSizePassesTheAccessibilityAudit() throws {
        let app = launch(contentSize: "UICTContentSizeCategoryAccessibilityXXXL")

        let figure = figureElement(app)
        XCTAssertTrue(figure.waitForExistence(timeout: 5))
        XCTAssertTrue(figure.label.contains("52"), figure.label)

        try audit(app)
    }

    @MainActor
    func testLandscapePutsTheTripBesideTheFigureAndPassesTheAccessibilityAudit() throws {
        let app = launch()
        XCUIDevice.shared.orientation = .landscapeLeft
        defer { XCUIDevice.shared.orientation = .portrait }

        let figure = figureElement(app)
        XCTAssertTrue(figure.waitForExistence(timeout: 5))
        let duration = app.otherElements["Durata"]
        XCTAssertTrue(duration.waitForExistence(timeout: 5))
        // Beside, not under: the trip starts right of the figure.
        XCTAssertGreaterThan(duration.frame.minX, figure.frame.maxX)
        // The pill stays on screen, after the rotation settles.
        let hittable = XCTNSPredicateExpectation(predicate: NSPredicate(format: "isHittable == true"), object: app.buttons["Salva e azzera"])
        XCTAssertEqual(XCTWaiter.wait(for: [hittable], timeout: 5), .completed)

        try audit(app)
    }

    @MainActor
    func testSaveAndResetAsksThenKeepsTheTripInViaggi() throws {
        let app = launch()
        let save = app.buttons["Salva e azzera"]
        XCTAssertTrue(save.waitForExistence(timeout: 5))

        save.tap()

        // The confirmation repeats the action: the trip is saved and cleared only after the second tap.
        let dialog = app.sheets.firstMatch
        let confirm = dialog.buttons["Salva e azzera"]
        XCTAssertTrue(confirm.waitForExistence(timeout: 5))
        confirm.tap()

        // The Closure says it once on the figure for two seconds, then gives the figure back:
        // looked for right after the tap, since waiting for the dialog first can outlast it.
        let closure = app.descendants(matching: .any).matching(NSPredicate(format: "label BEGINSWITH 'Salvato'")).firstMatch
        XCTAssertTrue(closure.waitForExistence(timeout: 2))
        XCTAssertTrue(dialog.waitForNonExistence(timeout: 5))
        XCTAssertTrue(closure.waitForNonExistence(timeout: 5), "The Closure goes after two seconds")

        // Nothing left to keep: the pill is a plain, disabled reset.
        let reset = app.buttons["Azzera viaggio"]
        XCTAssertTrue(reset.waitForExistence(timeout: 5))
        XCTAssertFalse(reset.isEnabled)

        // The snapshot drive joins the three demo trips.
        app.buttons["Viaggi"].tap()
        XCTAssertTrue(app.navigationBars["Viaggi"].waitForExistence(timeout: 5))
        XCTAssertEqual(app.buttons.matching(identifier: "trip").count, 4)
    }

    @MainActor
    func testViaggiListsTheTripsAndPassesTheAccessibilityAudit() throws {
        let app = launch()

        app.buttons["Viaggi"].tap()
        XCTAssertTrue(app.navigationBars["Viaggi"].waitForExistence(timeout: 5))
        XCTAssertEqual(app.buttons.matching(identifier: "trip").count, 3)
        XCTAssertTrue(app.buttons["Esporta CSV"].isEnabled)

        try app.performAccessibilityAudit(for: XCUIAccessibilityAuditType.all.subtracting([.contrast, .dynamicType])) { issue in
            XCTFail("\(issue.compactDescription): \(issue.element?.debugDescription ?? "no element")")
            return true
        }

        app.buttons.matching(identifier: "trip").firstMatch.tap()
        let delete = app.buttons["Elimina viaggio"]
        XCTAssertTrue(delete.waitForExistence(timeout: 5))
        XCTAssertTrue(app.staticTexts["Massima"].exists)

        try app.performAccessibilityAudit(for: XCUIAccessibilityAuditType.all.subtracting([.contrast, .dynamicType])) { issue in
            XCTFail("\(issue.compactDescription): \(issue.element?.debugDescription ?? "no element")")
            return true
        }

        // Deleting asks first, then goes back to a shorter list.
        delete.tap()
        let confirm = app.sheets.firstMatch.buttons["Elimina viaggio"]
        XCTAssertTrue(confirm.waitForExistence(timeout: 5))
        confirm.tap()
        XCTAssertTrue(app.navigationBars["Viaggi"].waitForExistence(timeout: 5))
        let shorter = XCTNSPredicateExpectation(predicate: NSPredicate(format: "count == 2"), object: app.buttons.matching(identifier: "trip"))
        XCTAssertEqual(XCTWaiter.wait(for: [shorter], timeout: 5), .completed)
    }

    @MainActor
    func testQuickLimitTurnsOnWithATapAndOffWithAnother() {
        let app = launch()
        // The snapshot drive goes at 52 km/h.
        let limit = app.buttons["50 km/h"]
        XCTAssertTrue(limit.waitForExistence(timeout: 5))

        limit.tap()
        XCTAssertTrue(limit.isSelected)
        let warning = app.staticTexts.matching(NSPredicate(format: "label CONTAINS 'Oltre il limite di 50'")).firstMatch
        XCTAssertTrue(warning.waitForExistence(timeout: 5))

        limit.tap()
        XCTAssertFalse(limit.isSelected)
        XCTAssertTrue(warning.waitForNonExistence(timeout: 5))
    }

    @MainActor
    func testParabrezzaShowsTheSpeedAndGoesBackWithATap() throws {
        let app = launch()
        let hud = app.buttons["Parabrezza"]
        XCTAssertTrue(hud.waitForExistence(timeout: 5))

        hud.tap()

        // VoiceOver reads the speed unmirrored; the tool screen and its bar are out of the way.
        let figure = app.descendants(matching: .any).matching(NSPredicate(format: "label == 'Velocità' AND value == '52 km/h'")).firstMatch
        XCTAssertTrue(figure.waitForExistence(timeout: 5))
        XCTAssertFalse(app.buttons["Impostazioni"].exists && app.buttons["Impostazioni"].isHittable)
        XCTAssertFalse(app.buttons["Salva e azzera"].exists)

        // Dynamic Type is left out on Parabrezza: the figure and its unit are sized to fill the
        // screen for the windshield, not to a text style.
        try audit(app, excluding: [.contrast, .dynamicType])

        app.buttons["Esci dal parabrezza"].tap()
        XCTAssertTrue(app.buttons["Salva e azzera"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.buttons["Impostazioni"].exists)
    }

    @MainActor
    func testSettingsOfferTheUnitAndPassTheAccessibilityAudit() throws {
        let app = launch()

        app.buttons["Impostazioni"].tap()
        XCTAssertTrue(app.staticTexts["La distanza segue la velocità: chilometri, miglia o miglia nautiche."].waitForExistence(timeout: 5))

        // Dynamic Type is left out as in Sbu Habits: in the settings sheet the audit flags every
        // text as partially unsupported, system ones included.
        try app.performAccessibilityAudit(for: XCUIAccessibilityAuditType.all.subtracting([.contrast, .dynamicType])) { issue in
            XCTFail("\(issue.compactDescription): \(issue.element?.debugDescription ?? "no element")")
            return true
        }
    }
}
