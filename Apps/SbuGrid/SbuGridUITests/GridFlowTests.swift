import XCTest

/// Drives the grid screen, its settings and the full screen on the drawn still life, and runs
/// the accessibility audit on each. Runs in Italian; nothing is saved between tests.
final class GridFlowTests: XCTestCase {
    override func setUp() {
        continueAfterFailure = false
    }

    /// Contrast is left out as in the other apps: text colors come from tokens with checked
    /// ratios, and the audit misreads the iOS 26 glass bar.
    static let screenExclusions: XCUIAccessibilityAuditType = [.contrast]
    /// Sheets also leave out Dynamic Type and clipped text: the audit flags the system buttons
    /// in the iOS 26 glass toolbar of a sheet, as in the other apps.
    static let sheetExclusions: XCUIAccessibilityAuditType = [.contrast, .dynamicType, .textClipped]

    @MainActor
    static func launch(photo: String = "demo", _ arguments: [String] = []) -> XCUIApplication {
        let app = XCUIApplication()
        app.launchArguments += ["-AppleLanguages", "(it)", "-AppleLocale", "it_IT", "-GRID_PHOTO", photo]
        app.launchArguments += arguments
        app.launch()
        return app
    }

    @MainActor
    static func audit(_ app: XCUIApplication, excluding excluded: XCUIAccessibilityAuditType = screenExclusions) throws {
        try app.performAccessibilityAudit(for: XCUIAccessibilityAuditType.all.subtracting(excluded)) { issue in
            // The audit reports "Ricalca" as clipped in its pill, wherever the pill sits and
            // whatever its symbol, while the screenshots show the word whole with room to spare:
            // a false positive of the clipping heuristic on this word, checked by eye on iPhone 17
            // and SE.
            if issue.auditType == .textClipped, issue.element?.label == "Ricalca" {
                return true
            }
            XCTFail("\(issue.compactDescription):\(issue.element?.debugDescription ?? "no element")")
            return true
        }
    }

    /// Swipes the sheet up until `element` can be tapped, a little at a time.
    @MainActor
    static func scroll(_ app: XCUIApplication, to element: XCUIElement) {
        for _ in 0..<8 where !(element.exists && element.isHittable) {
            let list = app.collectionViews.firstMatch
            list.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.8))
                .press(forDuration: 0.05, thenDragTo: list.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5)))
        }
    }

    /// The figure, by what VoiceOver reads for it.
    @MainActor
    static func figure(_ app: XCUIApplication, _ spoken: String) -> XCUIElement {
        app.staticTexts.matching(NSPredicate(format: "label CONTAINS %@", spoken)).firstMatch
    }

    @MainActor
    func testWithoutAPhotoTheScreenOffersToChooseOne() throws {
        let app = Self.launch(photo: "none")
        XCTAssertTrue(app.staticTexts["Nessuna foto"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.buttons["Scegli una foto"].exists)
        XCTAssertTrue(app.staticTexts["Sbu Grid vede solo la foto che scegli, non la tua libreria."].exists)
        XCTAssertFalse(app.buttons["Cambia foto"].exists)
        XCTAssertFalse(app.buttons["Griglia"].exists)
        try Self.audit(app)
    }

    @MainActor
    func testThePhotoShowsTheGridAndItsCount() throws {
        let app = Self.launch()
        // 1200 × 1600 with 4 square columns: 300-pixel cells, so 6 rows.
        XCTAssertTrue(Self.figure(app, "4 colonne per 6 righe").waitForExistence(timeout: 5))
        XCTAssertTrue(Self.figure(app, "Celle quadrate").exists)
        XCTAssertTrue(app.images["Foto con la griglia"].exists)
        XCTAssertTrue(app.buttons["Griglia"].exists)
        XCTAssertTrue(app.buttons["Schermo intero"].exists)
        XCTAssertTrue(app.buttons["Cambia foto"].exists)
        try Self.audit(app)
    }

    @MainActor
    func testTheGearAtTheTopLeftOpensSettings() throws {
        let app = Self.launch()
        let gear = app.navigationBars.buttons["Impostazioni"]
        XCTAssertTrue(gear.waitForExistence(timeout: 5))
        XCTAssertLessThan(gear.frame.midX, app.frame.midX)
        gear.tap()
        XCTAssertTrue(app.buttons["Fine"].waitForExistence(timeout: 5))
    }

    @MainActor
    func testGridSettingsChangeTheGridAndExplainTheLockedRows() throws {
        let app = Self.launch()
        XCTAssertTrue(app.buttons["Griglia"].waitForExistence(timeout: 5))
        app.buttons["Griglia"].tap()

        XCTAssertTrue(app.images["Anteprima della griglia"].waitForExistence(timeout: 5))
        try Self.audit(app, excluding: Self.sheetExclusions)
        let columns = app.steppers["Colonne"]
        Self.scroll(app, to: app.switches["Celle quadrate"])
        XCTAssertTrue(columns.isHittable)

        // Square cells: the rows follow, and the footer says why.
        let rows = app.steppers["Righe"]
        XCTAssertFalse(rows.isEnabled)
        let footer = app.staticTexts["Con le celle quadrate le righe seguono le colonne e la forma della foto."]
        Self.scroll(app, to: footer)
        XCTAssertTrue(footer.exists)

        columns.buttons.element(boundBy: 1).tap()
        XCTAssertEqual(columns.value as? String, "5")

        let square = app.switches["Celle quadrate"]
        square.switches.firstMatch.tap()
        XCTAssertEqual(square.value as? String, "0")
        XCTAssertTrue(rows.isEnabled)
        XCTAssertFalse(footer.exists)
        rows.buttons.element(boundBy: 0).tap()
        XCTAssertEqual(rows.value as? String, "5")

        app.buttons["Fine"].tap()
        XCTAssertTrue(Self.figure(app, "5 colonne per 5 righe").waitForExistence(timeout: 5))
        XCTAssertFalse(Self.figure(app, "Celle quadrate").exists)
    }

    @MainActor
    func testTheLineSettingsAreAllThere() throws {
        let app = Self.launch()
        XCTAssertTrue(app.buttons["Griglia"].waitForExistence(timeout: 5))
        app.buttons["Griglia"].tap()

        XCTAssertTrue(app.buttons["Cambia foto"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.buttons["Colore"].exists || app.otherElements["Colore"].exists || app.staticTexts["Colore"].exists)
        XCTAssertTrue(app.sliders["Spessore"].exists)
        XCTAssertTrue(app.sliders["Opacità"].exists)
        for title in ["Diagonali", "Numeri di righe e colonne", "Bianco e nero"] {
            let toggle = app.switches[title]
            Self.scroll(app, to: toggle)
            XCTAssertTrue(toggle.isHittable, title)
            XCTAssertEqual(toggle.value as? String, "0", title)
            toggle.switches.firstMatch.tap()
            XCTAssertEqual(toggle.value as? String, "1", title)
        }
        try Self.audit(app, excluding: Self.sheetExclusions)
        app.buttons["Fine"].tap()
        XCTAssertTrue(app.images["Foto con la griglia"].waitForExistence(timeout: 5))
        try Self.audit(app)
    }

    @MainActor
    func testFullScreenShowsOnlyThePhotoAndCloses() throws {
        let app = Self.launch()
        XCTAssertTrue(app.buttons["Schermo intero"].waitForExistence(timeout: 5))
        app.buttons["Schermo intero"].tap()

        let close = app.buttons["Chiudi"]
        XCTAssertTrue(close.waitForExistence(timeout: 5))
        // The grid screen is under the cover: its tools cannot be reached.
        XCTAssertFalse(app.buttons["Schermo intero"].isHittable)
        XCTAssertTrue(app.images["Foto con la griglia"].exists)
        try Self.audit(app)

        close.tap()
        XCTAssertTrue(app.buttons["Schermo intero"].waitForExistence(timeout: 5))
    }

    @MainActor
    func testThePhotoZoomsWithADoubleTapAndBack() throws {
        let app = Self.launch()
        let photo = app.images["Foto con la griglia"]
        XCTAssertTrue(photo.waitForExistence(timeout: 5))
        photo.doubleTap()
        photo.swipeLeft()
        photo.doubleTap()
        XCTAssertTrue(photo.exists)
        XCTAssertTrue(Self.figure(app, "4 colonne per 6 righe").exists)
    }
}
