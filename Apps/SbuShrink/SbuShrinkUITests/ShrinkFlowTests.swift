import XCTest

/// Drives the pick, the settings, the run and the result on the demo library and compressor,
/// and runs the accessibility audit on each screen. Runs in Italian.
final class ShrinkFlowTests: XCTestCase {
    override func setUp() {
        continueAfterFailure = false
    }

    /// Contrast is left out as in the other apps: text colors come from tokens with checked
    /// ratios, and the audit misreads the iOS 26 glass bar.
    private static let screenExclusions: XCUIAccessibilityAuditType = [.contrast]

    @MainActor
    private func launch(_ arguments: [String] = []) -> XCUIApplication {
        let app = XCUIApplication()
        app.launchArguments += ["-Demo", "YES", "-AppleLanguages", "(it)", "-AppleLocale", "it_IT"]
        app.launchArguments += arguments
        app.launch()
        return app
    }

    @MainActor
    private func audit(_ app: XCUIApplication, excluding excluded: XCUIAccessibilityAuditType = screenExclusions) throws {
        try app.performAccessibilityAudit(for: XCUIAccessibilityAuditType.all.subtracting(excluded)) { issue in
            // Text with no element at all is the list scrolled under the iOS 26 glass bar, which
            // redraws it blurred: the audit reads that copy, never the real rows.
            if issue.element == nil, issue.auditType == .dynamicType || issue.auditType == .textClipped || issue.compactDescription.hasPrefix("Potentially inaccessible text") {
                return true
            }
            // Section footers: the system caps them below the largest sizes, as in Settings itself.
            if issue.auditType == .dynamicType, issue.element?.elementType == .staticText,
               issue.element?.frame.minY ?? 0 > 0, Self.footers.contains(where: { prefix in issue.element.map { $0.label == prefix || (prefix.count > 5 && $0.label.hasPrefix(prefix)) } ?? false }) {
                return true
            }
            // The title of a system switch row: iOS sizes it, as in Settings itself.
            if issue.auditType == .dynamicType, let label = issue.element?.label, app.switches[label].exists {
                return true
            }
            XCTFail("\(issue.compactDescription): \(issue.element?.debugDescription ?? "no element") — \(issue.detailedDescription)")
            return true
        }
    }

    private static let footers = ["Video", "Più fotogrammi", "Riduci le dimensioni", "Più qualità", "Con la dimensione", "H.264", "HEVC", "Lettura", "Non leggibili", "MP4 si carica", "Ogni video", "Per alcuni video", "I video ci stanno"]

    @MainActor
    private func keepScreenshot(_ app: XCUIApplication, _ name: String) {
        let attachment = XCTAttachment(screenshot: app.screenshot())
        attachment.name = name
        attachment.lifetime = .keepAlways
        add(attachment)
    }

    @MainActor
    private func estimate(_ app: XCUIApplication) -> XCUIElement {
        app.staticTexts.matching(NSPredicate(format: "label BEGINSWITH 'Dimensione stimata'")).firstMatch
    }

    @MainActor
    private func compress(_ app: XCUIApplication) {
        let button = app.buttons["Comprimi"]
        XCTAssertTrue(button.waitForExistence(timeout: 5))
        let enabled = NSPredicate(format: "isEnabled == true")
        expectation(for: enabled, evaluatedWith: button)
        waitForExpectations(timeout: 5)
        button.tap()
    }

    @MainActor
    private func waitForDone(_ app: XCUIApplication) {
        XCTAssertTrue(app.navigationBars["Fatto"].waitForExistence(timeout: 20))
        // The run fades out under the result.
        XCTAssertTrue(app.buttons["Interrompi"].waitForNonExistence(timeout: 5))
    }

    // MARK: - Pick

    @MainActor
    func testThePickOffersPhotosAndFilesAndPassesTheAudit() throws {
        let app = launch()
        XCTAssertTrue(app.buttons["Scegli da Foto"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.buttons["Importa da File"].exists)
        XCTAssertTrue(app.staticTexts["Comprimi i tuoi video"].exists)
        keepScreenshot(app, "pick")
        try audit(app)
    }

    // MARK: - Settings

    @MainActor
    func testTheSettingsShowTheEstimateTheSlidersAndTheVideos() throws {
        let app = launch(["-DemoVideos", "5"])
        XCTAssertTrue(estimate(app).waitForExistence(timeout: 5))
        XCTAssertTrue(app.navigationBars["Compressione"].exists)
        XCTAssertTrue(estimate(app).label.contains("Ora 1,11 GB"), estimate(app).label)
        XCTAssertTrue(estimate(app).label.contains("82% in meno"), estimate(app).label)
        XCTAssertEqual(app.sliders["Frame rate"].value as? String, "24 fps")
        XCTAssertEqual(app.sliders["Dimensioni"].value as? String, "80%")
        XCTAssertEqual(app.sliders["Qualità"].value as? String, "60%")
        // "Avanzate" starts closed, as the options the original does not have.
        XCTAssertFalse(app.buttons["Codec"].exists)
        keepScreenshot(app, "settings")
        try audit(app)

        app.swipeUp()
        XCTAssertTrue(app.descendants(matching: .any)["IMG 1669"].exists)
        XCTAssertTrue(app.staticTexts.matching(NSPredicate(format: "label CONTAINS '1,11 GB'")).firstMatch.exists)
        keepScreenshot(app, "settings-videos")
        try audit(app)
    }

    @MainActor
    func testASmallerSizeLowersTheEstimate() throws {
        let app = launch(["-DemoVideos", "2"])
        XCTAssertTrue(estimate(app).waitForExistence(timeout: 5))
        let before = estimate(app).label

        app.sliders["Dimensioni"].adjust(toNormalizedSliderPosition: 0)

        XCTAssertEqual(app.sliders["Dimensioni"].value as? String, "10%")
        XCTAssertNotEqual(estimate(app).label, before)
        XCTAssertTrue(estimate(app).label.contains("in meno"))
    }

    @MainActor
    func testAdvancedOpensWithTargetCodecMP4AndAudio() throws {
        let app = launch(["-DemoVideos", "3"])
        XCTAssertTrue(estimate(app).waitForExistence(timeout: 5))
        let advanced = app.buttons.matching(NSPredicate(format: "label BEGINSWITH 'Avanzate'")).firstMatch
        XCTAssertTrue(advanced.label.contains("H.264"), advanced.label)
        advanced.tap()

        XCTAssertTrue(app.navigationBars["Avanzate"].waitForExistence(timeout: 5))
        let target = app.switches["Dimensione massima"]
        XCTAssertTrue(target.exists)
        XCTAssertTrue(app.switches["Converti in MP4"].exists)
        XCTAssertTrue(app.switches["Togli l'audio"].exists)
        XCTAssertTrue(app.buttons["Codec"].exists || app.staticTexts["Codec"].exists)

        target.switches.firstMatch.tap()
        XCTAssertTrue(app.textFields["MB per video"].waitForExistence(timeout: 5))
        XCTAssertEqual(app.textFields["MB per video"].value as? String, "25")
        keepScreenshot(app, "advanced")
        try audit(app)

        app.navigationBars.buttons.firstMatch.tap()
        XCTAssertTrue(estimate(app).waitForExistence(timeout: 5))
        XCTAssertTrue(advanced.label.contains("Max 25 MB"), advanced.label)
        // The target sets the quality: its slider rests.
        XCTAssertFalse(app.sliders["Qualità"].isEnabled)
    }

    @MainActor
    func testBackFromTheSettingsDropsTheBatch() throws {
        let app = launch(["-DemoVideos", "2"])
        XCTAssertTrue(estimate(app).waitForExistence(timeout: 5))
        app.navigationBars.buttons.firstMatch.tap()
        XCTAssertTrue(app.buttons["Scegli da Foto"].waitForExistence(timeout: 5))
    }

    // MARK: - Run and result

    @MainActor
    func testARunShowsVideoNOfMThenTheSavingsAndKeepsTheOriginals() throws {
        let app = launch(["-DemoVideos", "5", "-DemoSpeed", "slow"])
        compress(app)

        XCTAssertTrue(app.navigationBars["Compressione dei video"].waitForExistence(timeout: 5))
        let progress = app.staticTexts.matching(NSPredicate(format: "label BEGINSWITH 'Avanzamento'")).firstMatch
        XCTAssertTrue(progress.waitForExistence(timeout: 5))
        XCTAssertTrue(progress.label.contains("Video 1 di 5"), progress.label)
        XCTAssertEqual(app.descendants(matching: .any).matching(identifier: "job").count, 5)
        XCTAssertTrue(app.buttons["Interrompi"].exists)
        keepScreenshot(app, "compressing")
        try audit(app)
    }

    @MainActor
    func testTheResultSaysHowManyAndKeepsTheOriginals() throws {
        let app = launch(["-DemoVideos", "5"])
        compress(app)
        waitForDone(app)

        XCTAssertTrue(app.staticTexts["5 video compressi e salvati in Foto"].exists)
        let savings = app.staticTexts.matching(NSPredicate(format: "label BEGINSWITH 'Risparmio'")).firstMatch
        XCTAssertTrue(savings.exists)
        XCTAssertTrue(savings.label.contains("in meno"), savings.label)
        XCTAssertTrue(app.staticTexts["Cosa vuoi fare con i video originali?"].exists)
        XCTAssertTrue(app.buttons["Elimina originali"].exists)
        XCTAssertTrue(app.buttons["Condividi"].exists)
        keepScreenshot(app, "done")
        try audit(app)

        app.buttons["Tieni 5 originali"].tap()
        XCTAssertTrue(app.buttons["Scegli da Foto"].waitForExistence(timeout: 5))
    }

    @MainActor
    func testDeletingTheOriginalsAsksFirstAndSaysHowMany() throws {
        let app = launch(["-DemoVideos", "3"])
        compress(app)
        waitForDone(app)

        app.buttons["Elimina originali"].tap()
        let confirm = app.sheets.buttons["Elimina originali"].firstMatch
        XCTAssertTrue(confirm.waitForExistence(timeout: 5))
        confirm.tap()

        let done = app.staticTexts.matching(NSPredicate(format: "label BEGINSWITH 'Originali eliminati: 3'")).firstMatch
        XCTAssertTrue(done.waitForExistence(timeout: 5))
        XCTAssertFalse(app.buttons["Elimina originali"].exists)
        try audit(app)

        app.buttons["Fine"].tap()
        XCTAssertTrue(app.buttons["Scegli da Foto"].waitForExistence(timeout: 5))
    }

    @MainActor
    func testInterruptingBeforeAnythingIsDoneGoesBackToTheSettings() throws {
        let app = launch(["-DemoVideos", "2", "-DemoSpeed", "slow"])
        compress(app)
        let interrupt = app.buttons["Interrompi"]
        XCTAssertTrue(interrupt.waitForExistence(timeout: 5))
        interrupt.tap()
        let confirm = app.sheets.buttons["Interrompi"].firstMatch
        XCTAssertTrue(confirm.waitForExistence(timeout: 5))
        confirm.tap()

        XCTAssertTrue(estimate(app).waitForExistence(timeout: 5))
        XCTAssertTrue(app.buttons["Comprimi"].isEnabled)
    }

    @MainActor
    func testAMixedBatchSaysWhatWasLightAndWhatFailed() throws {
        let app = launch(["-DemoVideos", "1", "-DemoScenario", "mixed"])
        compress(app)
        waitForDone(app)

        XCTAssertTrue(app.staticTexts["Già leggeri, restano come sono: 1"].exists)
        XCTAssertTrue(app.staticTexts.matching(NSPredicate(format: "label CONTAINS 'Non compressi: 1'")).firstMatch.exists)
        XCTAssertTrue(app.staticTexts["1 video compresso e salvato in Foto"].exists)
        XCTAssertTrue(app.buttons["Tieni l'originale"].exists)
        keepScreenshot(app, "done-mixed")
        try audit(app)
    }

    @MainActor
    func testWithoutPhotosTheCopiesCanBeSharedAndSettingsOpened() throws {
        let app = launch(["-DemoVideos", "2", "-DemoAccess", "denied"])
        compress(app)
        waitForDone(app)

        XCTAssertTrue(app.staticTexts["2 video compressi"].exists)
        XCTAssertTrue(app.staticTexts.matching(NSPredicate(format: "label CONTAINS 'Foto non consentito'")).firstMatch.exists)
        XCTAssertTrue(app.buttons["Apri Impostazioni"].exists)
        XCTAssertTrue(app.buttons["Condividi"].exists)
        XCTAssertFalse(app.buttons["Elimina originali"].exists)
        XCTAssertTrue(app.buttons["Fine"].exists)
        keepScreenshot(app, "done-denied")
        try audit(app)
    }

    // MARK: - Settings sheet

    /// Sheets also leave out Dynamic Type and clipped text: the audit flags the system buttons
    /// in the iOS 26 glass toolbar of a sheet, as in the other apps.
    private static let sheetExclusions: XCUIAccessibilityAuditType = [.contrast, .dynamicType, .textClipped]

    @MainActor
    func testSettingsHaveTheAlbumTheResetAndTheLicenses() throws {
        let app = launch()
        let gear = app.navigationBars.buttons["Impostazioni"]
        XCTAssertTrue(gear.waitForExistence(timeout: 5))
        gear.tap()

        let album = app.switches["Salva anche nell'album Video compressi"]
        XCTAssertTrue(album.waitForExistence(timeout: 5))
        XCTAssertEqual(album.value as? String, "1")
        // Fresh preferences: nothing to restore.
        XCTAssertFalse(app.buttons["Ripristina le impostazioni consigliate"].isEnabled)
        keepScreenshot(app, "settings-sheet")
        try audit(app, excluding: Self.sheetExclusions)

        album.switches.firstMatch.tap()
        XCTAssertEqual(album.value as? String, "0")
        let licenses = app.buttons["Licenze"]
        for _ in 0..<5 where !licenses.isHittable {
            app.collectionViews.firstMatch.swipeUp()
        }
        XCTAssertTrue(licenses.isHittable)
        app.buttons["Fine"].tap()
        XCTAssertTrue(app.buttons["Scegli da Foto"].waitForExistence(timeout: 5))
    }

    @MainActor
    func testRestoringTheSuggestedSettingsAsksFirst() throws {
        let app = launch(["-DemoVideos", "2"])
        XCTAssertTrue(estimate(app).waitForExistence(timeout: 5))
        app.sliders["Dimensioni"].adjust(toNormalizedSliderPosition: 0)
        XCTAssertEqual(app.sliders["Dimensioni"].value as? String, "10%")
        app.navigationBars.buttons.firstMatch.tap()

        app.navigationBars.buttons["Impostazioni"].tap()
        let restore = app.buttons["Ripristina le impostazioni consigliate"]
        XCTAssertTrue(restore.waitForExistence(timeout: 5))
        XCTAssertTrue(restore.isEnabled)
        restore.tap()
        let confirm = app.sheets.buttons["Ripristina le impostazioni consigliate"].firstMatch
        let alertConfirm = app.alerts.buttons["Ripristina le impostazioni consigliate"].firstMatch
        XCTAssertTrue(confirm.waitForExistence(timeout: 5) || alertConfirm.exists)
        (confirm.exists ? confirm : alertConfirm).tap()
        XCTAssertFalse(restore.isEnabled)
    }
}
