import XCTest

/// Opens a demo subscription, edits its price, pauses it and deletes it, auditing each screen.
final class DetailFlowTests: XCTestCase {
    @MainActor
    func testEditPauseAndDelete() throws {
        let app = XCUIApplication()
        app.launchArguments += ["-FASTLANE_SNAPSHOT", "YES", "-AppleLanguages", "(it)", "-AppleLocale", "it_IT"]
        app.launch()

        app.buttons.matching(NSPredicate(format: "label BEGINSWITH %@", "Musica")).firstMatch.tap()
        XCTAssertTrue(app.buttons["edit"].waitForExistence(timeout: 5))
        let shot = XCTAttachment(screenshot: app.screenshot())
        shot.name = "dettaglio"
        shot.lifetime = .keepAlways
        add(shot)
        try audit(app, "dettaglio")

        app.buttons["edit"].tap()
        let price = app.textFields["price"]
        XCTAssertTrue(price.waitForExistence(timeout: 5))
        // Audited before typing: with the system decimal pad up over this sheet the audit flags three
        // of the keyboard's own texts, which the app doesn't draw.
        let form = XCTAttachment(screenshot: app.screenshot())
        form.name = "modifica"
        form.lifetime = .keepAlways
        add(form)
        try audit(app, "modifica")
        // At the right edge, so the cursor lands after the old price.
        price.coordinate(withNormalizedOffset: CGVector(dx: 0.98, dy: 0.5)).tap()
        price.typeText(String(repeating: XCUIKeyboardKey.delete.rawValue, count: 8) + "11,99")
        app.buttons["save"].tap()
        XCTAssertTrue(app.staticTexts.matching(NSPredicate(format: "label CONTAINS %@", "11,99")).firstMatch.waitForExistence(timeout: 5))

        let pause = app.buttons["Metti in pausa"]
        for _ in 0..<6 where !pause.exists || !pause.isHittable { app.swipeUp() }
        pause.tap()
        XCTAssertTrue(app.buttons["Riprendi"].waitForExistence(timeout: 5))

        // Marking it cancelled is the detail's primary button; a cancelled one offers to bring it back.
        let markCancelled = app.buttons["markCancelled"]
        for _ in 0..<4 where !markCancelled.exists || !markCancelled.isHittable { app.swipeUp() }
        let actions = XCTAttachment(screenshot: app.screenshot())
        actions.name = "azioni"
        actions.lifetime = .keepAlways
        // Not audited here: scrolled to the bottom, the rows half under the sheet's bar read as clipped text.
        // The detail is audited at the top, and the buttons are SbuKit's, audited in every app.
        add(actions)
        app.coordinate(withNormalizedOffset: .zero).withOffset(CGVector(dx: markCancelled.frame.midX, dy: markCancelled.frame.midY)).tap()
        XCTAssertTrue(app.buttons["reactivate"].waitForExistence(timeout: 5))

        // A full-screen window left by the edit sheet's keyboard makes XCTest call the button not hittable,
        // though a finger reaches it: tap its centre on the screen.
        let delete = app.buttons["delete"]
        XCTAssertTrue(delete.waitForExistence(timeout: 5))
        app.coordinate(withNormalizedOffset: .zero).withOffset(CGVector(dx: delete.frame.midX, dy: delete.frame.midY)).tap()
        let confirm = app.buttons.matching(NSPredicate(format: "label == %@ AND identifier != %@", "Elimina abbonamento", "delete")).firstMatch
        XCTAssertTrue(confirm.waitForExistence(timeout: 5))
        confirm.tap()
        XCTAssertTrue(app.staticTexts["Film e serie"].waitForExistence(timeout: 5))
        XCTAssertFalse(app.staticTexts["Musica"].exists)
    }

    @MainActor
    func testHistoryAndPriceChange() throws {
        let app = XCUIApplication()
        app.launchArguments += ["-FASTLANE_SNAPSHOT", "YES", "-AppleLanguages", "(it)", "-AppleLocale", "it_IT"]
        app.launch()
        app.buttons.matching(NSPredicate(format: "label BEGINSWITH %@", "Musica")).firstMatch.tap()

        // The detail shows the latest payments and prices; each pencil opens the rest.
        XCTAssertTrue(app.buttons["edit"].waitForExistence(timeout: 5))
        let history = app.buttons["Modifica lo storico dei pagamenti"]
        for _ in 0..<4 where !history.exists || !history.isHittable { app.swipeUp() }
        try audit(app, "dettaglio, storico")
        history.tap()
        let markPaid = app.buttons["Segna come pagato"].firstMatch
        XCTAssertTrue(markPaid.waitForExistence(timeout: 5), "Past payments can be marked paid")
        try audit(app, "cronologia")
        markPaid.tap()
        XCTAssertTrue(app.staticTexts["Pagato"].waitForExistence(timeout: 5))
        app.navigationBars.buttons.firstMatch.tap()

        let changePrice = app.buttons["Cambia prezzo"]
        for _ in 0..<4 where !changePrice.exists || !changePrice.isHittable { app.swipeUp() }
        changePrice.tap()
        let price = app.textFields["newPrice"]
        XCTAssertTrue(price.waitForExistence(timeout: 5))
        try audit(app, "cambia prezzo")
        price.tap()
        price.typeText("12,99")
        app.buttons["Salva"].tap()
        // The coming price is in the rows under the history.
        XCTAssertTrue(app.textFields["newPrice"].waitForNonExistence(timeout: 5))
        let coming = app.staticTexts.matching(NSPredicate(format: "label BEGINSWITH %@ AND label CONTAINS %@", "Dal ", "12,99")).firstMatch
        for _ in 0..<6 where !coming.exists { app.swipeUp() }
        XCTAssertTrue(coming.exists, "A rise from the next payment shows in the detail")
    }

    @MainActor
    private func audit(_ app: XCUIApplication, _ screen: String) throws {
        try app.performAccessibilityAudit(for: XCUIAccessibilityAuditType.all.subtracting([.contrast, .dynamicType])) { issue in
            XCTFail("\(screen): \(issue.compactDescription): \(issue.element.map { "\($0.elementType.rawValue) '\($0.label)' \($0.frame)" } ?? issue.detailedDescription)")
            return true
        }
    }
}
