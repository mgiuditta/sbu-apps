import XCTest

/// Settings: custom fields used in an item, export and import in place, the reminder off by default.
final class SettingsFlowTests: XCTestCase {
    override func setUp() {
        continueAfterFailure = false
    }

    @MainActor
    private func openSettings(_ app: XCUIApplication) {
        app.navigationBars.buttons["Impostazioni"].tap()
        XCTAssertTrue(app.element("exportCSV").waitForExistence(timeout: 5))
    }

    @MainActor
    func testSettingsOfferExportImportAndTheReminderOff() throws {
        let app = XCUIApplication.inventory(.sample)
        openSettings(app)
        XCTAssertTrue(app.element("exportArchive").exists)
        XCTAssertTrue(app.element("import").exists)
        let toggle = app.switches["reminderToggle"]
        XCTAssertTrue(toggle.exists)
        XCTAssertEqual(toggle.value as? String, "0")
        try app.audit()
    }

    @MainActor
    func testCustomFieldAppearsInTheItem() throws {
        let app = XCUIApplication.inventory(.sample)
        openSettings(app)
        app.element("fields").tap()
        app.element("addField").tap()
        let name = app.textFields["fieldName"]
        XCTAssertTrue(name.waitForExistence(timeout: 5))
        try app.audit()
        name.tap()
        name.typeText("Numero di serie")
        app.buttons["saveField"].tap()
        XCTAssertTrue(app.staticTexts["Numero di serie"].waitForExistence(timeout: 5))
        try app.audit()
        app.navigationBars.buttons.element(boundBy: 0).tap()
        app.buttons["Fine"].tap()

        app.element("folder-Casa").tap()
        app.element("folder-Cucina").tap()
        app.element("item-Moka").tap()
        app.element("editItem").tap()
        let field = app.textFields["field-Numero di serie"]
        XCTAssertTrue(field.waitForExistence(timeout: 5))
        field.tap()
        field.typeText("SN-42")
        app.buttons["saveItem"].tap()
        XCTAssertTrue(app.element(containing: "SN-42").waitForExistence(timeout: 5))
        try app.audit()
    }

    @MainActor
    func testEnglishShowsEnglishWords() throws {
        let app = XCUIApplication.inventory(.empty, language: "en")
        XCTAssertTrue(app.staticTexts["Empty inventory"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.buttons["Add item"].exists)
    }
}
