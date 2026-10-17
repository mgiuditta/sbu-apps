import XCTest

/// Drives every screen on the made-up sample chat and runs the accessibility audit on each.
/// Runs in Italian, on an in-memory store: the user's chats are never touched.
final class ChatsFlowTests: XCTestCase {
    override func setUp() {
        continueAfterFailure = false
    }

    @MainActor
    private func launch(seeded: Bool, textSize: String? = nil, language: String = "it") -> XCUIApplication {
        let app = XCUIApplication()
        let locale = language == "it" ? "it_IT" : "en_US"
        app.launchArguments += ["-AppleLanguages", "(\(language))", "-AppleLocale", locale, "-FASTLANE_SNAPSHOT", "YES"]
        if seeded { app.launchArguments += ["-SEED_SAMPLE", "YES"] }
        if let textSize { app.launchArguments += ["-UIPreferredContentSizeCategoryName", textSize] }
        app.launch()
        return app
    }

    /// SbuKit sizes the figure in grid cells rather than a text style, and draws the cartiglio in
    /// Plex Mono scaled by hand: on purpose, so the checks skip just those two elements.
    private static func isSbuKitGridType(_ issue: XCUIAccessibilityAuditIssue) -> Bool {
        guard let label = issue.element?.label else { return false }
        let isCartiglio = label.hasPrefix("SBU ·")
        // The figure's element, or its digits alone ("5342", "4.218").
        let isFigure = label.hasPrefix("Messaggi, ") || label.hasPrefix("Messages, ")
            || label.allSatisfy { $0.isNumber || $0 == "." || $0 == "," }
        switch issue.auditType {
        case .dynamicType: return isCartiglio || isFigure
        case .textClipped: return isCartiglio
        default: return false
        }
    }

    /// - Parameter checksDynamicType: `true` for the run at the largest text size.
    @MainActor
    private func audit(_ app: XCUIApplication, checksDynamicType: Bool = false) throws {
        // After a push the audit can catch rows mid-slide and report them clipped: let the screen settle.
        sleep(1)
        // Contrast and Dynamic Type are left out as in the other Sbu apps: colors come from tokens with
        // checked ratios, the audit misreads the iOS 26 glass bar, and large text has its own run.
        let excluded: XCUIAccessibilityAuditType = checksDynamicType ? [.contrast] : [.contrast, .dynamicType]
        try app.performAccessibilityAudit(for: XCUIAccessibilityAuditType.all.subtracting(excluded)) { issue in
            if Self.isSbuKitGridType(issue) { return true }
            // The system navigation-link Picker caps its own label at the largest sizes ("Periodo"
            // in body is set by the app; the cap is the system row's, and the audit reports it
            // only on some runs).
            if issue.auditType == .dynamicType, let label = issue.element?.label,
               label == "Periodo" || label == "Period" { return true }
            // No element: rows the screen's edge cuts in half, or blurred under the iOS 26 glass bar
            // after scrolling. Scrolling shows them whole.
            if issue.element == nil { return true }
            // The keyboard's own suggestion bar is the system's, not the app's.
            if let element = issue.element, app.keyboards.firstMatch.exists,
               app.keyboards.firstMatch.frame.insetBy(dx: 0, dy: -60).intersects(element.frame) { return true }
            // A list row grows with its text and wraps it, so it can't clip; the audit still measures
            // some icon-and-title rows from the icon's edge.
            if issue.auditType == .textClipped, let label = issue.element?.label,
               app.cells.staticTexts.matching(NSPredicate(format: "label == %@", label)).firstMatch.exists { return true }
            // The search field scrolls what you type.
            if issue.auditType == .textClipped, issue.element?.elementType == .searchField { return true }
            let shot = XCTAttachment(screenshot: app.screenshot())
            shot.name = issue.compactDescription
            shot.lifetime = .keepAlways
            self.add(shot)
            XCTFail("\(issue.compactDescription): \(issue.element?.debugDescription ?? "no element")")
            return true
        }
    }

    @MainActor
    private func openSampleChat(_ app: XCUIApplication) {
        let row = app.buttons.matching(NSPredicate(format: "label BEGINSWITH 'Chat di esempio'")).firstMatch
        XCTAssertTrue(row.waitForExistence(timeout: 15))
        row.tap()
        XCTAssertTrue(app.staticTexts["Tu · Giulia"].waitForExistence(timeout: 10))
    }

    /// Scrolls the screen until `element` can be tapped: lists build rows only near the screen.
    @MainActor
    private func reveal(_ element: XCUIElement, in app: XCUIApplication) {
        for _ in 0 ..< 16 where !(element.exists && element.isHittable) {
            // From low on the screen: on the chat the figure stays above the rows and doesn't scroll.
            app.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.9))
                .press(forDuration: 0.05, thenDragTo: app.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.7)))
        }
        XCTAssertTrue(element.isHittable, "\(element) not on screen")
    }

    @MainActor
    private func periodButton(_ app: XCUIApplication) -> XCUIElement {
        app.buttons.matching(NSPredicate(format: "label BEGINSWITH 'Periodo'")).firstMatch
    }

    @MainActor
    func testFirstLaunchExplainsHowToBringAChat() throws {
        let app = launch(seeded: false)
        XCTAssertTrue(app.buttons["Scegli un file"].waitForExistence(timeout: 10))
        XCTAssertTrue(app.staticTexts["Chat"].exists)
        XCTAssertTrue(app.buttons["Prova con una chat di esempio"].exists)
        XCTAssertTrue(app.buttons["Importa una chat"].exists)
        try audit(app)

        app.buttons["Come esportare una chat"].tap()
        XCTAssertTrue(app.staticTexts["Da iPhone"].waitForExistence(timeout: 5))
        try audit(app)
        reveal(app.staticTexts["WhatsApp è un marchio di Meta Platforms, Inc. Sbu Chats non è affiliata a Meta."], in: app)
    }

    @MainActor
    func testTheSampleChatAsksWhoYouAreThenShowsYourNumbers() throws {
        let app = launch(seeded: false)
        let sample = app.buttons["Prova con una chat di esempio"]
        XCTAssertTrue(sample.waitForExistence(timeout: 10))
        sample.tap()

        XCTAssertTrue(app.buttons["Nessuno di questi"].waitForExistence(timeout: 20))
        let confirm = app.buttons["Conferma"]
        XCTAssertFalse(confirm.isEnabled)
        try audit(app)
        app.buttons["Giulia"].tap()
        XCTAssertTrue(confirm.isEnabled)
        confirm.tap()

        // The import closes on the chat's figure with "Importata", then the figure comes back.
        let closure = app.descendants(matching: .any).matching(NSPredicate(format: "label == 'Importata'")).firstMatch
        XCTAssertTrue(closure.waitForExistence(timeout: 10))
        XCTAssertTrue(app.staticTexts["Tu · Giulia"].waitForExistence(timeout: 10))
        let gone = expectation(for: NSPredicate(format: "exists == false"), evaluatedWith: closure)
        wait(for: [gone], timeout: 5)
        XCTAssertTrue(figure(app).exists)
        try audit(app)
        reveal(app.staticTexts["Marco"], in: app)

        // Back in the list, the chat is there with its count.
        app.navigationBars.buttons.element(boundBy: 0).tap()
        XCTAssertTrue(app.buttons.matching(NSPredicate(format: "label BEGINSWITH 'Chat di esempio'")).firstMatch.waitForExistence(timeout: 5))
        try audit(app)
    }

    @MainActor
    func testActivityWordsAndSearch() throws {
        let app = launch(seeded: true)
        openSampleChat(app)
        try audit(app)

        reveal(app.buttons["Attività"], in: app)
        app.buttons["Attività"].tap()
        XCTAssertTrue(app.staticTexts.matching(NSPredicate(format: "label BEGINSWITH 'Il momento più attivo'")).firstMatch.waitForExistence(timeout: 5))
        try audit(app)
        for axis in ["Giorno", "Mese", "Anno"] {
            app.buttons[axis].tap()
            XCTAssertTrue(app.staticTexts.matching(NSPredicate(format: "label BEGINSWITH 'Il momento più attivo'")).firstMatch.waitForExistence(timeout: 5))
        }
        try audit(app)
        app.navigationBars.buttons.element(boundBy: 0).tap()

        reveal(app.buttons["Parole ed emoji"], in: app)
        app.buttons["Parole ed emoji"].tap()
        XCTAssertTrue(app.cells.element(boundBy: 2).waitForExistence(timeout: 10))
        try audit(app)
        app.buttons["Emoji"].tap()
        XCTAssertTrue(app.staticTexts["😂"].waitForExistence(timeout: 5))
        try audit(app)
        app.navigationBars.buttons.element(boundBy: 0).tap()

        reveal(app.buttons["Cerca nei messaggi"], in: app)
        app.buttons["Cerca nei messaggi"].tap()
        let field = app.searchFields.firstMatch
        XCTAssertTrue(field.waitForExistence(timeout: 5))
        try audit(app)
        field.tap()
        field.typeText("\"cena da me\"")
        XCTAssertTrue(app.staticTexts.matching(NSPredicate(format: "label ENDSWITH ' messaggi'")).firstMatch.waitForExistence(timeout: 5))
        try audit(app)
    }

    @MainActor
    func testThePeriodNarrowsEveryNumber() throws {
        let app = launch(seeded: true)
        openSampleChat(app)
        let total = figure(app)
        let before = total.label

        periodButton(app).tap()
        app.buttons["Ultimi 30 giorni"].tap()
        let changed = NSPredicate(format: "label != %@", before)
        expectation(for: changed, evaluatedWith: total)
        waitForExpectations(timeout: 10)
        XCTAssertTrue(app.staticTexts.matching(NSPredicate(format: "label BEGINSWITH 'Fino all'")).firstMatch.exists)
        try audit(app)

        periodButton(app).tap()
        app.buttons["Personalizzato"].tap()
        XCTAssertTrue(app.datePickers.firstMatch.waitForExistence(timeout: 5))
        try audit(app)
    }

    @MainActor
    func testAFileThatIsNotAChatSaysWhy() throws {
        let app = XCUIApplication()
        app.launchArguments += ["-AppleLanguages", "(it)", "-AppleLocale", "it_IT", "-FASTLANE_SNAPSHOT", "YES",
                                "-DEMO_IMPORT_TEXT", "Lista della spesa"]
        app.launch()
        XCTAssertTrue(app.staticTexts["Non riconosco il formato"].waitForExistence(timeout: 10))
        XCTAssertTrue(app.staticTexts["Lista della spesa"].exists)
        try audit(app)
        app.buttons["Chiudi"].tap()
        XCTAssertTrue(app.buttons["Scegli un file"].waitForExistence(timeout: 5))
    }

    @MainActor
    func testDeletingAChatAsksFirst() throws {
        let app = launch(seeded: true)
        let row = app.buttons.matching(NSPredicate(format: "label BEGINSWITH 'Chat di esempio'")).firstMatch
        XCTAssertTrue(row.waitForExistence(timeout: 15))
        row.swipeLeft()
        app.buttons["Elimina"].firstMatch.tap()
        XCTAssertTrue(app.staticTexts["Eliminare “Chat di esempio”?"].waitForExistence(timeout: 5))
        app.buttons.matching(NSPredicate(format: "label == 'Elimina'")).element(boundBy: 0).tap()
        XCTAssertTrue(app.buttons["Scegli un file"].waitForExistence(timeout: 5))
    }

    @MainActor
    func testRenameAndWhoYouAreFromTheChatMenu() throws {
        let app = launch(seeded: true)
        openSampleChat(app)
        app.buttons["Azioni della chat"].tap()
        app.buttons["Chi sei?"].tap()
        XCTAssertTrue(app.buttons["Nessuno di questi"].waitForExistence(timeout: 5))
        app.buttons["Marco"].tap()
        app.buttons["Conferma"].tap()
        XCTAssertTrue(app.staticTexts["Tu · Marco"].waitForExistence(timeout: 10))

        app.buttons["Azioni della chat"].tap()
        app.buttons["Rinomina"].tap()
        let field = app.textFields.firstMatch
        XCTAssertTrue(field.waitForExistence(timeout: 5))
        field.clearAndType("Marco e Giulia")
        app.alerts.buttons["Rinomina"].tap()
        XCTAssertTrue(app.navigationBars["Marco e Giulia"].waitForExistence(timeout: 5))
    }

    /// The figure: one element, "Messaggi, 4.218, …".
    @MainActor
    private func figure(_ app: XCUIApplication) -> XCUIElement {
        app.descendants(matching: .any).matching(NSPredicate(format: "label BEGINSWITH 'Messaggi, '")).firstMatch
    }

    /// At the largest text size the title, the figure and the rows stay on screen and readable.
    @MainActor
    func testLargestTextKeepsTheChatReadable() throws {
        let app = launch(seeded: true, textSize: "UICTContentSizeCategoryAccessibilityXXXL")
        XCTAssertTrue(app.buttons.matching(NSPredicate(format: "label BEGINSWITH 'Chat di esempio'")).firstMatch.waitForExistence(timeout: 15))
        try audit(app, checksDynamicType: true)
        openSampleChat(app)
        XCTAssertTrue(figure(app).isHittable)
        try audit(app, checksDynamicType: true)
        reveal(periodButton(app), in: app)
        reveal(app.buttons["Cerca nei messaggi"], in: app)
    }

    @MainActor
    func testEnglishInterface() throws {
        let app = launch(seeded: true, language: "en")
        let row = app.buttons.matching(NSPredicate(format: "label BEGINSWITH 'Sample chat'")).firstMatch
        XCTAssertTrue(row.waitForExistence(timeout: 15))
        row.tap()
        XCTAssertTrue(app.staticTexts["You · Emma"].waitForExistence(timeout: 10))
        reveal(app.buttons["Words and Emoji"], in: app)
        try audit(app)
    }
}

private extension XCUIElement {
    /// Replaces the field's text.
    func clearAndType(_ text: String) {
        tap()
        if let current = value as? String, !current.isEmpty {
            typeText(String(repeating: XCUIKeyboardKey.delete.rawValue, count: current.count))
        }
        typeText(text)
    }
}
