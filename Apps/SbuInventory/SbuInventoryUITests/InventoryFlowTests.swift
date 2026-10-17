import XCTest

/// Drives the inventory like a person would: first item, a folder, moving, searching, deleting.
final class InventoryFlowTests: XCTestCase {
    override func setUp() {
        continueAfterFailure = false
    }

    @MainActor
    func testFirstItemShowsInTheTotal() throws {
        let app = XCUIApplication.inventory(.empty)
        XCTAssertTrue(app.element("addFirst").waitForExistence(timeout: 5))
        try app.audit()

        app.element("addFirst").tap()
        let name = app.textFields["itemName"]
        XCTAssertTrue(name.waitForExistence(timeout: 5))
        try app.audit()
        name.tap()
        name.typeText("Trapano")
        app.buttons["saveItem"].tap()

        // The new item closes the total with "Aggiunto" for two seconds, then the figure is back.
        // The audit waits it out: the Closure's word shrinks to fit, which the audit reads as clipped.
        let closure = app.staticTexts["Aggiunto"]
        XCTAssertTrue(closure.waitForExistence(timeout: 5))
        XCTAssertTrue(closure.waitForNonExistence(timeout: 5))

        let total = app.element("total")
        XCTAssertTrue(total.waitForExistence(timeout: 5))
        XCTAssertTrue(total.label.contains("1"), total.label)
        XCTAssertTrue(app.element("item-Trapano").exists)
        try app.audit()
    }

    @MainActor
    func testFolderMoveSearchAndDelete() throws {
        let app = XCUIApplication.inventory(.empty)
        app.addItem("Pile AA", quantity: 4)
        app.addFolder("Garage")
        XCTAssertTrue(app.element("folder-Garage").waitForExistence(timeout: 5))

        // Sposta in: the item goes into the folder.
        let item = app.element("item-Pile AA")
        item.swipeLeft()
        app.buttons["Sposta in"].tap()
        XCTAssertTrue(app.navigationBars.staticTexts["Sposta «Pile AA»"].waitForExistence(timeout: 5))
        try app.audit()
        app.buttons["Garage"].tap()
        XCTAssertTrue(app.element("folder-Garage").waitForExistence(timeout: 5))
        XCTAssertFalse(app.element("item-Pile AA").exists)

        // The folder's own screen counts it.
        app.element("folder-Garage").tap()
        XCTAssertTrue(app.navigationBars["Garage"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.element("total").label.contains("4"), app.element("total").label)
        try app.audit()
        app.navigationBars.buttons.element(boundBy: 0).tap()

        // Search finds it from the top, with its path.
        let search = app.searchFields.firstMatch
        search.tap()
        search.typeText("pile")
        XCTAssertTrue(app.staticTexts["Garage"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.element("item-Pile AA").exists)
        app.clearSearch()

        // Deleting the folder asks first and says what goes with it.
        app.element("folder-Garage").swipeLeft()
        app.buttons["Elimina"].tap()
        let alert = app.alerts.firstMatch
        XCTAssertTrue(alert.waitForExistence(timeout: 5))
        XCTAssertTrue(alert.staticTexts["Va via anche quello che contiene: 1 voce, con le foto."].exists)
        alert.buttons["Elimina"].tap()
        XCTAssertTrue(app.element("addFirst").waitForExistence(timeout: 5))
    }

    @MainActor
    func testItemDetailChangesQuantityAndDeletes() throws {
        let app = XCUIApplication.inventory(.sample)
        app.element("folder-Casa").tap()
        app.element("folder-Garage").tap()
        app.element("item-Pile AA").tap()

        let figure = app.element("quantity")
        XCTAssertTrue(figure.waitForExistence(timeout: 5))
        XCTAssertTrue(figure.label.contains("2"), figure.label)
        XCTAssertTrue(app.staticTexts["Da ricomprare"].exists)
        try app.audit()

        app.steppers["quantityStepper"].buttons.element(boundBy: 1).tap()
        XCTAssertTrue(figure.label.contains("3"), figure.label)

        app.element("deleteItem").tap()
        app.buttons["Elimina oggetto"].firstMatch.tap()
        XCTAssertTrue(app.navigationBars["Garage"].waitForExistence(timeout: 5))
        XCTAssertFalse(app.element("item-Pile AA").exists)
    }

    @MainActor
    func testSampleIsAddedAndGoesWithOneDelete() throws {
        let app = XCUIApplication.inventory(.empty)
        app.element("addSample").tap()
        XCTAssertTrue(app.element("folder-Esempio").waitForExistence(timeout: 5))
        XCTAssertTrue(app.element("total").label.contains("41"), app.element("total").label)
        app.element("folder-Esempio").swipeLeft()
        app.buttons["Elimina"].tap()
        app.alerts.firstMatch.buttons["Elimina"].tap()
        XCTAssertTrue(app.element("addFirst").waitForExistence(timeout: 5))
    }

    @MainActor
    func testInventorySurvivesRelaunch() throws {
        let file = "uitest-\(UUID().uuidString).store"
        let app = XCUIApplication()
        app.launchArguments += ["-AppleLanguages", "(it)", "-AppleLocale", "it_IT"]
        app.launchEnvironment["SBU_STORE_FILE"] = file
        app.launch()
        app.element("addSample").tap()
        XCTAssertTrue(app.element("folder-Esempio").waitForExistence(timeout: 5))

        app.terminate()
        app.launch()
        XCTAssertTrue(app.element("folder-Esempio").waitForExistence(timeout: 5))
        XCTAssertTrue(app.element("total").label.contains("41"), app.element("total").label)
    }

    @MainActor
    func testCancelWithChangesAsksFirst() throws {
        let app = XCUIApplication.inventory(.empty)
        app.element("addFirst").tap()
        let name = app.textFields["itemName"]
        XCTAssertTrue(name.waitForExistence(timeout: 5))
        name.tap()
        name.typeText("Trapano")
        app.tapCancel()
        let alert = app.alerts.firstMatch
        XCTAssertTrue(alert.waitForExistence(timeout: 5))
        alert.buttons["Continua a modificare"].tap()
        XCTAssertEqual(name.value as? String, "Trapano")
        app.tapCancel()
        app.alerts.firstMatch.buttons["Ignora le modifiche"].tap()
        XCTAssertTrue(app.element("addFirst").waitForExistence(timeout: 5))
    }

    @MainActor
    func testToolScreenPassesTheAuditAtTheLargestTextSize() throws {
        let app = XCUIApplication.inventory(.sample, textSize: "UICTContentSizeCategoryAccessibilityXXXL")
        XCTAssertTrue(app.element("total").waitForExistence(timeout: 5))
        try app.audit()
        app.terminate()

        let empty = XCUIApplication.inventory(.empty, textSize: "UICTContentSizeCategoryAccessibilityXXXL")
        // At this size the buttons start below the fold: the title says the screen is up.
        XCTAssertTrue(empty.staticTexts["Inventario"].waitForExistence(timeout: 5))
        try empty.audit()
    }

    @MainActor
    func testLowStockListAndScope() throws {
        let app = XCUIApplication.inventory(.sample)
        app.element("lowStock").tap()
        XCTAssertTrue(app.navigationBars["Da ricomprare"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.element("item-Pile AA").exists)
        XCTAssertFalse(app.element("item-Trapano").exists)
        try app.audit()
    }
}
