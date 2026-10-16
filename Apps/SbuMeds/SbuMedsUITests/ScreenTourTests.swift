import XCTest

/// Walks every screen on the made-up family and saves a screenshot of each to `MEDS_TOUR_DIR`,
/// for the visual check before a device test. Skipped when the variable is not set
/// (`TEST_RUNNER_MEDS_TOUR_DIR=/path xcodebuild test …`).
final class ScreenTourTests: MedsUITestCase {
    @MainActor
    func testTour() throws {
        guard let path = ProcessInfo.processInfo.environment["MEDS_TOUR_DIR"] else {
            throw XCTSkip("Set MEDS_TOUR_DIR to save the tour")
        }
        let directory = URL(fileURLWithPath: path)
        let app = XCUIApplication()
        app.launchArguments += ["-AppleLanguages", "(it)", "-AppleLocale", "it_IT", "-FASTLANE_SNAPSHOT", "YES"]
        app.launchArguments += ProcessInfo.processInfo.environment["MEDS_TOUR_ARGS"]?.split(separator: " ").map(String.init) ?? []
        app.launch()

        func save(_ name: String) throws {
            sleep(1)
            try XCUIScreen.main.screenshot().pngRepresentation.write(to: directory.appending(path: "\(name).png"))
        }

        XCTAssertTrue(app.buttons.matching(identifier: "dose").firstMatch.waitForExistence(timeout: 5))
        try save("01-today")
        app.swipeUp()
        try save("02-today-bottom")
        app.swipeDown(velocity: .fast)
        app.swipeDown(velocity: .fast)

        app.buttons.matching(identifier: "dose").firstMatch.tap()
        try save("03-dose")
        app.buttons["closeDose"].tap()

        app.navigationBars.buttons.element(boundBy: 1).tap()
        try save("04-settings")
        app.swipeUp()
        try save("05-settings-bottom")
        app.swipeDown(velocity: .fast)
        app.swipeDown(velocity: .fast)
        XCTAssertTrue(app.buttons["medicines"].waitForExistence(timeout: 5))

        app.buttons["personPicker"].tap()
        app.buttons["Nonna Rita"].tap()
        try save("06-grandma")

        app.buttons["medicines"].tap()
        XCTAssertTrue(app.buttons["addPerson"].waitForExistence(timeout: 5) || app.buttons.matching(identifier: "medicine").firstMatch.exists)
        try save("07-medicines")
        app.swipeUp()
        try save("08-medicines-bottom")
        app.swipeDown(velocity: .fast)

        app.buttons.matching(identifier: "medicine").firstMatch.tap()
        XCTAssertTrue(app.buttons["editMedicine"].waitForExistence(timeout: 5))
        try save("09-medicine")
        app.swipeUp()
        try save("10-medicine-bottom")
        app.buttons["editMedicine"].tap()
        XCTAssertTrue(app.textFields["medicineName"].waitForExistence(timeout: 5))
        try save("11-edit")
        app.swipeUp()
        try save("12-edit-bottom")
        app.buttons["Annulla"].tap()
        app.navigationBars.buttons.firstMatch.tap()

        if app.buttons["report"].waitForExistence(timeout: 2) {
            app.buttons["report"].tap()
            try save("13-report")
        }
    }
}
