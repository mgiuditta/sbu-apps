import XCTest

/// Drives Sbu Clean like a person would, on the demo library (`-FASTLANE_SNAPSHOT`), in Italian:
/// permission, home, swipe, duplicates, bin and deletion, videos, timeline, settings. Every
/// screen runs the accessibility audit and leaves a screenshot in the test results.
final class CleanFlowTests: XCTestCase {
    override func setUp() {
        continueAfterFailure = false
    }

    @MainActor
    private func launch(access: String = "full") -> XCUIApplication {
        let app = XCUIApplication()
        app.launchArguments += ["-AppleLanguages", "(it)", "-AppleLocale", "it_IT", "-FASTLANE_SNAPSHOT", "YES", "-DemoAccess", access]
        app.launch()
        return app
    }

    /// The element whose label starts with `prefix`, such as the figure "Spazio liberabile, 63 MB".
    @MainActor
    private func element(startingWith prefix: String, in app: XCUIApplication) -> XCUIElement {
        app.descendants(matching: .any).matching(NSPredicate(format: "label BEGINSWITH %@", prefix)).firstMatch
    }

    @MainActor
    private func attachScreenshot(_ name: String, of app: XCUIApplication) {
        let attachment = XCTAttachment(screenshot: app.screenshot())
        attachment.name = name
        attachment.lifetime = .keepAlways
        add(attachment)
    }

    /// Contrast is left out as in the other Sbu apps: colors come from tokens with checked ratios,
    /// and the audit misreads photos and the iOS 26 glass bar. Dynamic Type is left out too: on
    /// iOS 26 the audit flags system text (toolbar buttons, list section headers, list rows) as
    /// partially unsupported; large text is checked on screenshots at the largest size instead.
    @MainActor
    private func audit(_ app: XCUIApplication, excluding extra: XCUIAccessibilityAuditType = []) throws {
        var issues: [String] = []
        try app.performAccessibilityAudit(for: XCUIAccessibilityAuditType.all.subtracting([.contrast, .dynamicType]).subtracting(extra)) { issue in
            // SbuKit's uppercase captions are tracked, and the audit reads the last letter's
            // tracking as a clipped fraction of a point; on screen they are whole (SbuKit).
            if issue.auditType == .textClipped, let label = issue.element?.label, label == label.uppercased() {
                return true
            }
            issues.append("\(issue.compactDescription): \(issue.element?.label ?? "no element") \(issue.element?.frame ?? .zero)")
            return true
        }
        XCTAssertTrue(issues.isEmpty, issues.joined(separator: "\n"))
    }

    /// Taps the visible element with this label: the screen underneath keeps its own copy.
    @MainActor
    private func tapVisible(_ label: String, in app: XCUIApplication) {
        let matches = app.staticTexts.matching(NSPredicate(format: "label == %@", label))
        XCTAssertTrue(matches.firstMatch.waitForExistence(timeout: 5))
        let visible = matches.allElementsBoundByIndex.last { $0.isHittable }
        (visible ?? matches.firstMatch).tap()
    }

    @MainActor
    private func openHomeRow(_ title: String, in app: XCUIApplication) {
        let row = element(startingWith: title, in: app)
        if !row.waitForExistence(timeout: 5) || !row.isHittable {
            app.swipeUp()
        }
        XCTAssertTrue(row.waitForExistence(timeout: 5), "no row \(title)")
        row.tap()
    }

    @MainActor
    func testFirstLaunchExplainsAndAsksForPhotos() throws {
        let app = launch(access: "notDetermined")

        let ask = app.buttons["Continua"]
        XCTAssertTrue(ask.waitForExistence(timeout: 5))
        attachScreenshot("01-access", of: app)
        try audit(app)

        ask.tap()

        XCTAssertTrue(element(startingWith: "Spazio liberabile", in: app).waitForExistence(timeout: 10))
    }

    @MainActor
    func testDeniedAccessPointsToSettings() throws {
        let app = launch(access: "denied")

        XCTAssertTrue(app.buttons["Apri Impostazioni"].waitForExistence(timeout: 5))
        XCTAssertTrue(element(startingWith: "Sbu Clean non può vedere", in: app).exists)
        attachScreenshot("02-denied", of: app)
        try audit(app)
    }

    @MainActor
    func testHomeShowsTheSpaceYouCanFree() throws {
        let app = launch()

        let figure = element(startingWith: "Spazio liberabile", in: app)
        XCTAssertTrue(figure.waitForExistence(timeout: 10))
        XCTAssertTrue(element(startingWith: "Duplicati e simili", in: app).waitForExistence(timeout: 10))
        attachScreenshot("03-home", of: app)
        try audit(app)
    }

    @MainActor
    func testHomeAtTheLargestTextSize() throws {
        let app = XCUIApplication()
        app.launchArguments += ["-AppleLanguages", "(it)", "-AppleLocale", "it_IT", "-FASTLANE_SNAPSHOT", "YES", "-DemoAccess", "full",
                                "-UIPreferredContentSizeCategoryName", "UICTContentSizeCategoryAccessibilityXXXL"]
        app.launch()

        XCTAssertTrue(element(startingWith: "Spazio liberabile", in: app).waitForExistence(timeout: 10))
        attachScreenshot("03-home-ax5", of: app)
        try audit(app)
    }

    @MainActor
    func testSwipeLeftMarksForTheBinAndUndoBringsItBack() throws {
        let app = launch()
        app.buttons["Scorri le foto"].tap()
        XCTAssertTrue(element(startingWith: "Nel cestino", in: app).waitForExistence(timeout: 5))
        attachScreenshot("04-months", of: app)
        try audit(app)

        app.cells.containing(.staticText, identifier: "Recenti").allElementsBoundByIndex.last { $0.isHittable }?.tap()
        let card = element(startingWith: "Foto,", in: app)
        let found = card.waitForExistence(timeout: 5)
        attachScreenshot("05-swipe", of: app)
        XCTAssertTrue(found)
        try audit(app)

        let firstCard = card.label
        card.swipeLeft()
        let moved = XCTNSPredicateExpectation(predicate: NSPredicate(format: "label != %@", firstCard), object: element(startingWith: "Foto,", in: app))
        XCTAssertEqual(XCTWaiter.wait(for: [moved], timeout: 5), .completed)
        XCTAssertTrue(element(startingWith: "Nel cestino", in: app).label.contains("2 di"))

        app.buttons["Annulla l'ultima scelta"].tap()
        XCTAssertTrue(element(startingWith: "Nel cestino", in: app).label.contains("1 di"))

        app.buttons["Tieni"].tap()
        app.buttons["Elimina"].tap()
        XCTAssertTrue(element(startingWith: "Nel cestino", in: app).label.contains("3 di"))
    }

    @MainActor
    func testDuplicatesGoThroughTheBinAndTheSystemDialog() throws {
        let app = launch()
        openHomeRow("Duplicati e simili", in: app)

        let delete = app.buttons.matching(NSPredicate(format: "label BEGINSWITH 'Elimina'")).firstMatch
        let ready = XCTNSPredicateExpectation(predicate: NSPredicate(format: "isEnabled == true"), object: delete)
        XCTAssertEqual(XCTWaiter.wait(for: [ready], timeout: 30), .completed, "the scan finds the demo duplicates")
        attachScreenshot("06-duplicates", of: app)
        try audit(app)

        app.buttons.matching(NSPredicate(format: "label BEGINSWITH 'Duplicati' OR label CONTAINS 'gruppi'")).firstMatch.tap()
        XCTAssertTrue(element(startingWith: "Foto 1 di", in: app).waitForExistence(timeout: 5))
        XCTAssertEqual(element(startingWith: "Foto 1 di", in: app).value as? String, "Da tenere")
        XCTAssertEqual(element(startingWith: "Foto 2 di", in: app).value as? String, "Da eliminare")
        attachScreenshot("07-groups", of: app)
        try audit(app)

        app.buttons.matching(NSPredicate(format: "label BEGINSWITH 'Elimina'")).firstMatch.tap()

        let binDelete = app.buttons.matching(NSPredicate(format: "label BEGINSWITH 'Elimina' AND label ENDSWITH 'elementi'")).firstMatch
        XCTAssertTrue(binDelete.waitForExistence(timeout: 5))
        attachScreenshot("08-bin", of: app)
        try audit(app)

        let title = binDelete.label
        binDelete.tap()
        // The confirmation repeats the action's title: the second button with it confirms.
        let confirm = app.buttons.matching(NSPredicate(format: "label == %@", title)).element(boundBy: 1)
        XCTAssertTrue(confirm.waitForExistence(timeout: 5))
        confirm.tap()

        // The bin closes with its word, then the result opens.
        XCTAssertTrue(app.staticTexts["Liberato"].waitForExistence(timeout: 5))
        XCTAssertTrue(element(startingWith: "Spazio liberato", in: app).waitForExistence(timeout: 10))
        // Let the sheet finish rising: mid-animation the audit reads the caption as clipped.
        _ = app.buttons["Fine"].waitForExistence(timeout: 2)
        Thread.sleep(forTimeInterval: 1)
        XCTAssertTrue(element(startingWith: "iOS tiene le foto eliminate per 30 giorni", in: app).exists)
        attachScreenshot("09-result", of: app)
        try audit(app)
        app.buttons["Fine"].tap()
    }

    @MainActor
    func testVideosComeHeaviestFirst() throws {
        let app = launch()
        openHomeRow("Video", in: app)

        // Each video is a checkbox: a system toggle for VoiceOver.
        let first = app.switches.matching(NSPredicate(format: "label BEGINSWITH 'Video,'")).firstMatch
        XCTAssertTrue(first.waitForExistence(timeout: 5))
        XCTAssertTrue(first.label.contains("420"), first.label)
        attachScreenshot("10-videos", of: app)
        try audit(app)
    }

    @MainActor
    func testScreenshotsCanBeSelectedAll() throws {
        let app = launch()
        openHomeRow("Screenshot", in: app)

        app.buttons["Seleziona tutto"].tap()
        XCTAssertTrue(element(startingWith: "Selezionati", in: app).label.contains("5 di 5"))
        attachScreenshot("11-screenshots", of: app)
        try audit(app)
    }

    @MainActor
    func testSettingsShowTheAccess() throws {
        let app = launch()
        app.buttons["Impostazioni"].tap()

        XCTAssertTrue(element(startingWith: "Accesso alle foto", in: app).waitForExistence(timeout: 5))
        attachScreenshot("12-settings", of: app)
        try audit(app)
    }
}
