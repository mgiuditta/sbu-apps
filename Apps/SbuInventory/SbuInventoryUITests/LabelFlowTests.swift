import XCTest

/// The label flow where the simulator can't scan: you type the code, link it, and find the item again.
final class LabelFlowTests: XCTestCase {
    override func setUp() {
        continueAfterFailure = false
    }

    @MainActor
    private func find(_ code: String, in app: XCUIApplication) {
        app.element("scan").tap()
        let field = app.textFields["labelCode"]
        XCTAssertTrue(field.waitForExistence(timeout: 5))
        field.typeText(code)
        app.buttons["labelConfirm"].tap()
    }

    @MainActor
    func testUnknownLabelLinksToABoxThenOpensIt() throws {
        let app = XCUIApplication.inventory(.sample)
        find("BOX-3", in: app)

        XCTAssertTrue(app.staticTexts["Etichetta nuova"].waitForExistence(timeout: 5))
        // The code of an unknown label is never shown.
        XCTAssertFalse(app.staticTexts["BOX-3"].exists)
        try app.audit()
        app.element("folder-Scatola 3").tapWhenReady()
        XCTAssertTrue(app.navigationBars["Scatola 3"].waitForExistence(timeout: 5))

        app.navigationBars.buttons.element(boundBy: 0).tap()
        find("BOX-3", in: app)
        XCTAssertTrue(app.navigationBars["Scatola 3"].waitForExistence(timeout: 5))
    }

    @MainActor
    func testNewItemWithAScannedLabel() throws {
        let app = XCUIApplication.inventory(.empty)
        find("8001234567890", in: app)
        XCTAssertTrue(app.staticTexts["Etichetta nuova"].waitForExistence(timeout: 5))
        sleep(1)
        app.element("addWithLabel").tapWhenReady()
        let name = app.textFields["itemName"]
        XCTAssertTrue(name.waitForExistence(timeout: 5))
        name.typeText("Caffe")
        app.buttons["saveItem"].tap()
        // Saved, it opens: the label is on it.
        XCTAssertTrue(app.navigationBars["Caffe"].waitForExistence(timeout: 5))
        app.navigationBars.buttons.element(boundBy: 0).tap()
        XCTAssertTrue(app.element("item-Caffe").waitForExistence(timeout: 5))

        find("8001234567890", in: app)
        XCTAssertTrue(app.navigationBars["Caffe"].waitForExistence(timeout: 5))
        // Its own label is shown on the item, in the Etichetta row.
        XCTAssertTrue(app.element(containing: "8001234567890").exists)
    }

    @MainActor
    func testManualEntryScreenPassesTheAudit() throws {
        let app = XCUIApplication.inventory(.sample)
        app.element("scan").tap()
        XCTAssertTrue(app.textFields["labelCode"].waitForExistence(timeout: 5))
        try app.audit()
    }
}
