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
        app.launchArguments += ["-showsUnnamed", "NO", "-playsSound", "NO", "-vibrates", "NO", "-remembersPlaces", "NO"]
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

    /// The rows in the order they are on screen, by what VoiceOver reads: label, then value.
    @MainActor
    private func rowLabels(_ app: XCUIApplication) -> [String] {
        devices(app).allElementsBoundByIndex.map { "\($0.label), \($0.value as? String ?? "")" }
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
        XCTAssertTrue(labels[0].hasPrefix("Buds Pro, 80%"), labels[0])
        XCTAssertTrue(labels[0].contains("Auricolari"), labels[0])
        XCTAssertTrue(labels[0].contains("Qui vicino"), labels[0])
        XCTAssertTrue(labels[1].hasPrefix("WH-1000XM5"), labels[1])
        XCTAssertTrue(labels[5].hasPrefix("Mi Band 8"), labels[5])
        XCTAssertTrue(labels[5].contains("Freddo"), labels[5])
        XCTAssertTrue(app.staticTexts["Dispositivi senza nome nascosti: 3. Puoi mostrarli in Impostazioni."].exists)
        XCTAssertTrue(app.staticTexts["Altri dispositivi"].exists)
        XCTAssertFalse(app.staticTexts["Ricerca…"].exists)
        try audit(app)
    }

    @MainActor
    func testNothingNearbySaysSoAfterTheFirstSecondsAndOffersSearchAgain() throws {
        let app = launch(scanner: "empty")
        // The first seconds: the header's spinner, and no "nothing nearby" yet.
        XCTAssertTrue(app.staticTexts["Altri dispositivi"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.staticTexts["Ricerca dei dispositivi vicini…"].exists)

        let nothing = app.staticTexts["Nessun dispositivo vicino. Tienilo acceso e fuori dalla custodia."]
        XCTAssertTrue(nothing.waitForExistence(timeout: 10))
        let searchAgain = app.buttons["Cerca di nuovo"]
        XCTAssertTrue(searchAgain.exists)
        try audit(app)

        searchAgain.tap()
        XCTAssertTrue(app.staticTexts["Ricerca dei dispositivi vicini…"].waitForExistence(timeout: 5))
    }

    @MainActor
    func testPullingTheListDownSearchesAgain() throws {
        let app = launch()
        XCTAssertTrue(devices(app).firstMatch.waitForExistence(timeout: 5))
        let start = app.collectionViews.firstMatch.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.2))
        start.press(forDuration: 0.1, thenDragTo: start.withOffset(CGVector(dx: 0, dy: 400)))
        // The fixed devices advertise four times a second: the list fills again at once.
        XCTAssertTrue(devices(app).firstMatch.waitForExistence(timeout: 5))
        XCTAssertEqual(rowLabels(app).count, 6)
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
        app.descendants(matching: .any).matching(identifier: "figure").firstMatch
    }

    /// What VoiceOver reads for the figure: "Segnale", then the percentage and the word.
    @MainActor
    private func figureValue(_ app: XCUIApplication) -> String {
        "\(figure(app).label), \(figure(app).value as? String ?? "")"
    }

    @MainActor
    func testATapOnARowOpensItsFinderWithOneFigureAndTheWord() throws {
        let app = launch()
        let row = devices(app).firstMatch
        XCTAssertTrue(row.waitForExistence(timeout: 5))

        row.tap()

        XCTAssertTrue(figure(app).waitForExistence(timeout: 5))
        XCTAssertTrue(app.navigationBars["Buds Pro"].exists)
        // -52 dBm: 80%, Qui vicino.
        XCTAssertTrue(figureValue(app).contains("80%"), figureValue(app))
        XCTAssertTrue(figureValue(app).contains("Qui vicino"), figureValue(app))
        XCTAssertTrue(app.staticTexts["Muoviti per far crescere il segnale"].exists)
        XCTAssertTrue(app.switches["Avvisami se lo perdi"].exists)
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
    func testASilentDeviceShowsWhereItWasLastHeardAndIsListedAsHeardBefore() throws {
        let app = launch(scanner: "fading", ["-remembersPlaces", "YES"])
        let row = devices(app).firstMatch
        XCTAssertTrue(row.waitForExistence(timeout: 5))
        row.tap()

        // Silent after two seconds, off the list ten seconds later: then its sighting is saved.
        XCTAssertTrue(app.staticTexts["Visto l'ultima volta"].waitForExistence(timeout: 20))
        XCTAssertTrue(app.staticTexts["È dove era il tuo iPhone quando l'ha sentito: da lì inizia a cercare."].exists)
        try audit(app)

        app.navigationBars.buttons.firstMatch.tap()
        XCTAssertTrue(app.staticTexts["Sentiti prima"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.buttons.matching(identifier: "sighting").firstMatch.label.hasPrefix("Buds Pro"))
    }

    @MainActor
    func testSettingsOfferToRememberPlaces() throws {
        let app = launch()
        XCTAssertTrue(devices(app).firstMatch.waitForExistence(timeout: 5))
        app.navigationBars.buttons["Impostazioni"].tap()
        let places = app.switches["Ricorda dove li hai sentiti"]
        for _ in 0..<5 where !places.isHittable {
            app.collectionViews.firstMatch.swipeUp()
        }
        XCTAssertTrue(places.isHittable)
        XCTAssertEqual(places.value as? String, "0")
        places.switches.firstMatch.tap()
        let on = NSPredicate(format: "value == '1'")
        expectation(for: on, evaluatedWith: places)
        waitForExpectations(timeout: 5)
        try audit(app, excluding: Self.sheetExclusions)
    }

    @MainActor
    func testADeviceAddedToMyDevicesGoesToTheTopWithItsNameAndCanBeRemoved() throws {
        let app = launch()
        let row = devices(app).element(boundBy: 1)
        XCTAssertTrue(row.waitForExistence(timeout: 5))
        XCTAssertTrue(row.label.hasPrefix("WH-1000XM5"), row.label)
        row.tap()

        let pin = app.navigationBars.buttons["Aggiungi ai miei dispositivi"]
        XCTAssertTrue(pin.waitForExistence(timeout: 5))
        pin.tap()
        let field = app.alerts.textFields.firstMatch
        XCTAssertTrue(field.waitForExistence(timeout: 5))
        field.clearAndType("Le mie cuffie")
        app.alerts.buttons["Salva"].tap()
        XCTAssertTrue(app.navigationBars["Le mie cuffie"].waitForExistence(timeout: 5))

        app.navigationBars.buttons.firstMatch.tap()
        XCTAssertTrue(app.staticTexts["I miei dispositivi"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.staticTexts["Altri dispositivi"].exists)
        let first = devices(app).firstMatch
        XCTAssertTrue(first.label.hasPrefix("Le mie cuffie"), first.label)
        try audit(app)

        first.tap()
        let menu = app.navigationBars.buttons["Il mio dispositivo"]
        XCTAssertTrue(menu.waitForExistence(timeout: 5))
        menu.tap()
        let confirm = app.sheets.buttons["Togli dai miei dispositivi"].firstMatch
        XCTAssertTrue(confirm.waitForExistence(timeout: 5))
        confirm.tap()
        XCTAssertTrue(app.navigationBars["WH-1000XM5"].waitForExistence(timeout: 5))
    }

    @MainActor
    func testTheSingleEarbudGuideOpensFromTheFinderAndFromHelp() throws {
        let app = launch()
        let row = devices(app).firstMatch
        XCTAssertTrue(row.waitForExistence(timeout: 5))
        row.tap()

        let link = app.buttons["Hai perso un solo auricolare?"]
        for _ in 0..<3 where !link.isHittable {
            app.swipeUp()
        }
        link.tap()
        XCTAssertTrue(app.navigationBars["Un auricolare solo"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.staticTexts.matching(NSPredicate(format: "label BEGINSWITH 'Passo 1'")).firstMatch.exists)
        // Clipped text with "no element" is the iOS 26 glass bar over the list, as in Sbu Level's
        // info page: every row of the guide is still checked for Dynamic Type.
        try audit(app, excluding: [.contrast, .textClipped])

        app.navigationBars.buttons.firstMatch.tap()
        app.navigationBars.buttons.firstMatch.tap()
        app.navigationBars.buttons["Aiuto"].tap()
        let guide = app.buttons["Guida passo per passo"]
        for _ in 0..<5 where !guide.isHittable {
            app.collectionViews.firstMatch.swipeUp()
        }
        guide.tap()
        XCTAssertTrue(app.navigationBars["Un auricolare solo"].waitForExistence(timeout: 5))
    }

    @MainActor
    func testConnectedHeadphonesCanBeRungAndStopped() throws {
        let app = launch()
        let row = devices(app).firstMatch
        XCTAssertTrue(row.waitForExistence(timeout: 5))
        row.tap()

        let ring = app.buttons["Fai suonare Buds Pro"]
        for _ in 0..<3 where !ring.isHittable {
            app.swipeUp()
        }
        XCTAssertTrue(ring.isHittable)
        XCTAssertTrue(app.staticTexts.matching(NSPredicate(format: "label BEGINSWITH 'Funziona solo con le cuffie ancora collegate'")).firstMatch.exists)

        ring.tap()
        let stop = app.buttons["Ferma il suono"]
        XCTAssertTrue(stop.waitForExistence(timeout: 5))
        try audit(app)
        stop.tap()
        XCTAssertTrue(app.buttons["Fai suonare Buds Pro"].waitForExistence(timeout: 5))
    }

    @MainActor
    func testTheLostAlertSwitchTurnsOnAndSaysItsLimits() throws {
        let app = launch()
        let row = devices(app).firstMatch
        XCTAssertTrue(row.waitForExistence(timeout: 5))
        row.tap()

        let alert = app.switches["Avvisami se lo perdi"]
        XCTAssertTrue(alert.waitForExistence(timeout: 5))
        XCTAssertEqual(alert.value as? String, "0")
        XCTAssertTrue(app.staticTexts.matching(NSPredicate(format: "label BEGINSWITH 'Ti avvisa se non lo senti per 15 secondi'")).firstMatch.exists)

        alert.switches.firstMatch.tap()
        let on = NSPredicate(format: "value == '1'")
        expectation(for: on, evaluatedWith: alert)
        waitForExpectations(timeout: 5)
        try audit(app)
    }

    @MainActor
    func testTheFinderSaysWhenTheDeviceFallsSilent() throws {
        let app = launch(scanner: "fading")
        let row = devices(app).firstMatch
        XCTAssertTrue(row.waitForExistence(timeout: 5))
        row.tap()

        let silent = NSPredicate(format: "value CONTAINS 'Non sentito da'")
        expectation(for: silent, evaluatedWith: figure(app))
        waitForExpectations(timeout: 10)
        // The last figure stays, with the word replaced by the silence.
        XCTAssertTrue(figureValue(app).contains("80%"), figureValue(app))
        try audit(app)
    }

    @MainActor
    func testHelpAtTheTopRightSaysTheLimitsAndOpensFindMy() throws {
        let app = launch()
        let help = app.navigationBars.buttons["Aiuto"]
        XCTAssertTrue(help.waitForExistence(timeout: 5))
        XCTAssertGreaterThan(help.frame.midX, app.frame.midX)

        help.tap()

        XCTAssertTrue(app.staticTexts["Per ritrovarlo"].waitForExistence(timeout: 5))
        try audit(app, excluding: Self.sheetExclusions)
        let findMy = app.buttons["Apri Dov'è"]
        for _ in 0..<5 where !findMy.isHittable {
            app.collectionViews.firstMatch.swipeUp()
        }
        XCTAssertTrue(findMy.isHittable)
        XCTAssertTrue(app.staticTexts["Se hai perso un solo AirPod"].exists)
        try audit(app, excluding: Self.sheetExclusions)

        app.buttons["Fine"].tap()
        XCTAssertTrue(devices(app).firstMatch.waitForExistence(timeout: 5))
    }

    @MainActor
    func testSettingsShowTheUnnamedDevicesAndTheLicenses() throws {
        let app = launch()
        XCTAssertTrue(devices(app).firstMatch.waitForExistence(timeout: 5))
        app.navigationBars.buttons["Impostazioni"].tap()

        let unnamed = app.switches["Mostra dispositivi senza nome"]
        XCTAssertTrue(unnamed.waitForExistence(timeout: 5))
        XCTAssertEqual(unnamed.value as? String, "0")
        XCTAssertTrue(app.switches["Suono"].exists)
        XCTAssertTrue(app.switches["Vibrazione"].exists)
        try audit(app, excluding: Self.sheetExclusions)

        unnamed.switches.firstMatch.tap()
        XCTAssertEqual(unnamed.value as? String, "1")
        let licenses = app.buttons["Licenze"]
        for _ in 0..<5 where !licenses.isHittable {
            app.collectionViews.firstMatch.swipeUp()
        }
        XCTAssertTrue(licenses.isHittable)
        app.buttons["Fine"].tap()

        // The three demo devices without a name join the list, and the footer goes.
        XCTAssertTrue(app.buttons.matching(NSPredicate(format: "label BEGINSWITH 'Senza nome'")).firstMatch.waitForExistence(timeout: 5))
        XCTAssertFalse(app.staticTexts[Self.hiddenFooter].exists)
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
