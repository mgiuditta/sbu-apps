import XCTest

/// Drives the list, the finder, help and settings with the fixed scanner, and runs the
/// accessibility audit on each. Runs in Italian; the simulator has no Bluetooth.
final class FindFlowTests: XCTestCase {
    override func setUp() {
        continueAfterFailure = false
    }

    /// Contrast is left out as in the other apps: text colors come from tokens with checked
    /// ratios, and the audit misreads the iOS 26 glass bar.
    private static let screenExclusions: XCUIAccessibilityAuditType = [.contrast]
    /// Sheets also leave out Dynamic Type and clipped text: the audit flags the system buttons
    /// in the iOS 26 glass toolbar of a sheet, as in the other apps.
    private static let sheetExclusions: XCUIAccessibilityAuditType = [.contrast, .dynamicType, .textClipped]

    @MainActor
    private func launch(scanner: String = "demo", _ arguments: [String] = []) -> XCUIApplication {
        let app = XCUIApplication()
        app.launchArguments += ["-AppleLanguages", "(it)", "-AppleLocale", "it_IT", "-FIXED_SCANNER", scanner]
        // Arguments win over saved settings: every test starts from the defaults.
        app.launchArguments += ["-showsUnnamed", "NO", "-playsSound", "NO", "-vibrates", "NO"]
        app.launchArguments += arguments
        app.launch()
        return app
    }

    /// The footer under the list: the system caps section footers below the largest sizes and
    /// the audit reports them as "partially unsupported", as in Settings itself.
    private static let hiddenFooter = "Dispositivi senza nome nascosti: 3. Puoi mostrarli in Impostazioni."

    @MainActor
    private func audit(
        _ app: XCUIApplication,
        excluding excluded: XCUIAccessibilityAuditType = screenExclusions,
        systemFooters: Set<String> = [hiddenFooter]
    ) throws {
        try app.performAccessibilityAudit(for: XCUIAccessibilityAuditType.all.subtracting(excluded)) { issue in
            if issue.auditType == .dynamicType, let label = issue.element?.label, systemFooters.contains(label) {
                return true
            }
            XCTFail("\(issue.compactDescription):\(issue.element?.debugDescription ?? "no element")")
            return true
        }
    }

    /// The rows in the order they are on screen, by their combined VoiceOver labels.
    @MainActor
    private func rowLabels(_ app: XCUIApplication) -> [String] {
        devices(app).allElementsBoundByIndex.map(\.label)
    }

    @MainActor
    private func devices(_ app: XCUIApplication) -> XCUIElementQuery {
        app.buttons.matching(identifier: "device")
    }

    @MainActor
    func testTheListShowsNamedDevicesStrongestFirstAndPassesTheAudit() throws {
        let app = launch()
        let first = devices(app).firstMatch
        XCTAssertTrue(first.waitForExistence(timeout: 5))

        let labels = rowLabels(app)
        XCTAssertEqual(labels.count, 6, "\(labels)")
        XCTAssertTrue(labels[0].hasPrefix("Buds Pro"), labels[0])
        XCTAssertTrue(labels[0].contains("Auricolari"), labels[0])
        XCTAssertTrue(labels[0].contains("Qui vicino"), labels[0])
        XCTAssertTrue(labels[1].hasPrefix("WH-1000XM5"), labels[1])
        XCTAssertTrue(labels[5].hasPrefix("Mi Band 8"), labels[5])
        XCTAssertTrue(labels[5].contains("Freddo"), labels[5])
        XCTAssertTrue(app.staticTexts["Dispositivi senza nome nascosti: 3. Puoi mostrarli in Impostazioni."].exists)
        XCTAssertTrue(app.buttons["Cerca di nuovo"].exists)
        try audit(app)
    }

    @MainActor
    func testSearchAgainEmptiesTheListAndHearsTheDevicesAgain() throws {
        let app = launch()
        XCTAssertTrue(devices(app).firstMatch.waitForExistence(timeout: 5))

        app.buttons["Cerca di nuovo"].tap()

        // The fixed devices advertise four times a second: the list fills again at the next refresh.
        XCTAssertTrue(devices(app).firstMatch.waitForExistence(timeout: 5))
        XCTAssertEqual(rowLabels(app).count, 6)
    }

    @MainActor
    func testNoDeviceYetSaysTheSearchIsRunning() throws {
        let app = launch(scanner: "empty")
        XCTAssertTrue(app.staticTexts["Ricerca in corso"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.buttons["Cerca di nuovo"].exists)
        try audit(app)
    }

    @MainActor
    func testTheGearAtTheTopLeftOpensSettings() throws {
        let app = launch()
        let gear = app.navigationBars.buttons["Impostazioni"]
        XCTAssertTrue(gear.waitForExistence(timeout: 5))
        XCTAssertLessThan(gear.frame.midX, app.frame.midX)

        gear.tap()

        XCTAssertTrue(app.buttons["Fine"].waitForExistence(timeout: 5))
    }

    @MainActor
    private func figure(_ app: XCUIApplication) -> XCUIElement {
        app.staticTexts.matching(NSPredicate(format: "label BEGINSWITH 'Vicinanza'")).firstMatch
    }

    @MainActor
    func testATapOnARowOpensItsFinderWithOneFigureAndTheWord() throws {
        let app = launch()
        let row = devices(app).firstMatch
        XCTAssertTrue(row.waitForExistence(timeout: 5))

        row.tap()

        XCTAssertTrue(figure(app).waitForExistence(timeout: 5))
        XCTAssertTrue(app.navigationBars["Buds Pro"].exists)
        // -52 dBm: 80 out of 100, Qui vicino.
        XCTAssertTrue(figure(app).label.contains("80 su 100"), figure(app).label)
        XCTAssertTrue(figure(app).label.contains("Qui vicino"), figure(app).label)
        XCTAssertTrue(app.staticTexts["Muoviti piano e gira su te stesso: il numero sale quando ti avvicini. Non è una distanza."].exists)
        try audit(app)

        app.navigationBars.buttons.firstMatch.tap()
        XCTAssertTrue(devices(app).firstMatch.waitForExistence(timeout: 5))
    }

    @MainActor
    func testTheSoundAndVibrationPillsAreTheSettingsSwitches() throws {
        let app = launch()
        let row = devices(app).firstMatch
        XCTAssertTrue(row.waitForExistence(timeout: 5))
        row.tap()

        let sound = app.buttons["Suono"]
        let vibration = app.buttons["Vibrazione"]
        XCTAssertTrue(sound.waitForExistence(timeout: 5))
        XCTAssertFalse(sound.isSelected)
        XCTAssertFalse(vibration.isSelected)

        sound.tap()
        XCTAssertTrue(sound.isSelected)
        try audit(app)

        app.navigationBars.buttons.firstMatch.tap()
        app.navigationBars.buttons["Impostazioni"].tap()
        let soundSwitch = app.switches["Suono"]
        XCTAssertTrue(soundSwitch.waitForExistence(timeout: 5))
        XCTAssertEqual(soundSwitch.value as? String, "1")
        XCTAssertEqual(app.switches["Vibrazione"].value as? String, "0")
    }

    @MainActor
    func testTheFinderSaysWhenTheDeviceFallsSilent() throws {
        let app = launch(scanner: "fading")
        let row = devices(app).firstMatch
        XCTAssertTrue(row.waitForExistence(timeout: 5))
        row.tap()

        let silent = app.staticTexts.matching(NSPredicate(format: "label CONTAINS 'Non sentito da'")).firstMatch
        XCTAssertTrue(silent.waitForExistence(timeout: 10))
        // The last figure stays, with the word replaced by the silence.
        XCTAssertTrue(figure(app).label.contains("80 su 100"), figure(app).label)
        try audit(app)
    }

    @MainActor
    func testDeniedBluetoothSaysSoAndOffersSettings() throws {
        let app = launch(scanner: "denied")
        XCTAssertTrue(app.staticTexts["Bluetooth non consentito"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.buttons["Apri Impostazioni"].exists)
        try audit(app)
    }

    @MainActor
    func testBluetoothOffSaysHowToTurnItOnWithoutASettingsButton() throws {
        let app = launch(scanner: "poweredOff")
        XCTAssertTrue(app.staticTexts["Bluetooth spento"].waitForExistence(timeout: 5))
        XCTAssertFalse(app.buttons["Apri Impostazioni"].exists)
        try audit(app)
    }

    @MainActor
    func testUnsupportedSaysTheDeviceCannotScan() throws {
        let app = launch(scanner: "unsupported")
        XCTAssertTrue(app.staticTexts["Bluetooth non disponibile"].waitForExistence(timeout: 5))
        try audit(app)
    }
}
