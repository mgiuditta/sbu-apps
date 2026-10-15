import XCTest

/// Visits every screen and sheet on the sample house and saves a screenshot of each, for the review
/// at light, dark, English and the largest text sizes. Runs only when SBU_SHOTS_DIR names a folder
/// (`TEST_RUNNER_SBU_SHOTS_DIR=… xcodebuild test`); SBU_SHOTS_LANGUAGE and SBU_SHOTS_TEXT_SIZE pick the rest.
final class ScreenTourTests: XCTestCase {
    private var directory: String?
    private var prefix = ""

    override func setUpWithError() throws {
        continueAfterFailure = true
        let environment = ProcessInfo.processInfo.environment
        directory = environment["SBU_SHOTS_DIR"]
        try XCTSkipIf(directory == nil, "Set SBU_SHOTS_DIR to take the screen tour.")
        prefix = environment["SBU_SHOTS_PREFIX"] ?? "shot"
    }

    @MainActor
    private func save(_ app: XCUIApplication, _ name: String) {
        guard let directory else { return }
        sleep(1)
        let url = URL(fileURLWithPath: directory).appendingPathComponent("\(prefix)-\(name).png")
        try? app.screenshot().pngRepresentation.write(to: url)
    }

    @MainActor
    private func launch(_ store: XCUIApplication.Store) -> XCUIApplication {
        let environment = ProcessInfo.processInfo.environment
        return XCUIApplication.inventory(store, language: environment["SBU_SHOTS_LANGUAGE"] ?? "it",
                                         textSize: environment["SBU_SHOTS_TEXT_SIZE"] ?? "UICTContentSizeCategoryL")
    }

    @MainActor
    func testTour() {
        let empty = launch(.empty)
        save(empty, "01-empty")
        empty.element("addFirst").tap()
        save(empty, "02-new-item")
        empty.swipeUp()
        save(empty, "03-new-item-bottom")
        empty.terminate()

        let app = launch(.sample)
        save(app, "04-home")
        app.element("folder-Casa").tap()
        save(app, "05-folder")
        app.element("folder-Garage").tap()
        save(app, "06-garage")
        app.element("folderMenu").tap()
        save(app, "07-folder-menu")
        app.buttons["Sposta in"].firstMatch.tap()
        save(app, "08-move")
        app.tapCancel()

        app.element("item-Pile AA").firstMatch.tap()
        save(app, "09-item")
        app.swipeUp()
        save(app, "10-item-bottom")
        app.element("deleteItem").tap()
        save(app, "11-item-delete")
        // A bubble at the default sizes, an alert at the accessibility ones: Annulla, or a tap outside.
        if app.alerts.firstMatch.exists {
            app.alerts.firstMatch.tapCancel()
        } else {
            app.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.15)).tap()
        }
        app.element("editItem").tap()
        save(app, "12-edit-item")
        app.swipeUp()
        app.swipeUp()
        save(app, "13-edit-item-bottom")
        app.tapCancel()
        app.navigationBars.buttons.element(boundBy: 0).tap()
        app.navigationBars.buttons.element(boundBy: 0).tap()

        app.element("folder-Garage").swipeLeft()
        save(app, "14-swipe")
        app.buttons.element(matching: NSPredicate(format: "label == %@ OR label == %@", "Elimina", "Delete")).firstMatch.tap()
        save(app, "15-folder-delete")
        app.alerts.firstMatch.tapCancel()
        app.navigationBars.buttons.element(boundBy: 0).tap()

        app.element("lowStock").tap()
        save(app, "16-low-stock")
        app.navigationBars.buttons.element(boundBy: 0).tap()

        let search = app.searchFields.firstMatch
        search.tap()
        search.typeText("ca")
        save(app, "17-search")
        app.clearSearch()

        app.element("scan").tap()
        save(app, "18-scan-manual")
        app.textFields["labelCode"].typeText("BOX-9")
        app.buttons["labelConfirm"].tap()
        save(app, "19-unknown-label")
        app.tapCancel()

        app.navigationBars.buttons.element(boundBy: app.navigationBars.buttons.count - 1).tap()
        save(app, "20-settings")
        app.swipeUp()
        save(app, "21-settings-bottom")
        app.element("fields").tap()
        save(app, "22-fields-empty")
        app.element("addField").tap()
        save(app, "23-new-field")
    }
}
