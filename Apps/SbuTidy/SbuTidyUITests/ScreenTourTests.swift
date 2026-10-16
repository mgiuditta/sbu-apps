import XCTest

/// Walks every screen on the made-up home and saves a screenshot of each to `TIDY_TOUR_DIR`, for
/// the visual check before a device test. Skipped when the variable is not set
/// (`TEST_RUNNER_TIDY_TOUR_DIR=/path xcodebuild test …`).
final class ScreenTourTests: TidyUITestCase {
    @MainActor
    func testTour() throws {
        guard let path = ProcessInfo.processInfo.environment["TIDY_TOUR_DIR"] else {
            throw XCTSkip("Set TIDY_TOUR_DIR to save the tour")
        }
        let directory = URL(fileURLWithPath: path)
        let app = XCUIApplication()
        app.launchArguments += ["-AppleLanguages", "(it)", "-AppleLocale", "it_IT", "-FASTLANE_SNAPSHOT", "YES", "-today.filter", "toDo"]
        app.launchArguments += ProcessInfo.processInfo.environment["TIDY_TOUR_ARGS"]?.split(separator: " ").map(String.init) ?? []
        app.launch()

        func save(_ name: String) throws {
            try XCUIScreen.main.screenshot().pngRepresentation.write(to: directory.appending(path: "\(name).png"))
        }

        XCTAssertTrue(app.buttons.matching(identifier: "chore").firstMatch.waitForExistence(timeout: 5))
        try save("01-today")
        app.buttons["In scadenza"].tap()
        try save("02-upcoming")
        app.buttons["Da fare"].tap()

        app.buttons["rooms"].tap()
        XCTAssertTrue(app.buttons.matching(identifier: "room").firstMatch.waitForExistence(timeout: 5))
        try save("03-rooms")
        app.buttons.matching(identifier: "room").firstMatch.tap()
        XCTAssertTrue(app.buttons["addChore"].waitForExistence(timeout: 5))
        try save("04-room")

        app.buttons["addChore"].tap()
        XCTAssertTrue(app.textFields["choreName"].waitForExistence(timeout: 5))
        try save("05-new-chore")
        app.buttons["presets"].tap()
        try save("06-presets")
        app.navigationBars.buttons.firstMatch.tap()
        app.buttons["Annulla"].tap()

        app.buttons["roomMenu"].tap()
        try save("07-room-menu")
        app.buttons["Modifica stanza"].tap()
        XCTAssertTrue(app.buttons["saveRoom"].waitForExistence(timeout: 5))
        try save("08-edit-room")
        app.buttons["Annulla"].tap()

        app.buttons.matching(identifier: "chore").firstMatch.tap()
        XCTAssertTrue(app.buttons["doneNow"].waitForExistence(timeout: 5))
        try save("09-chore")
        app.swipeUp()
        try save("10-chore-bottom")
        app.buttons["doneOn"].tap()
        XCTAssertTrue(app.buttons["confirmDoneOn"].waitForExistence(timeout: 5))
        try save("11-done-on")
        app.buttons["Annulla"].tap()
        app.buttons["editChore"].tap()
        XCTAssertTrue(app.buttons["saveChore"].waitForExistence(timeout: 5))
        try save("12-edit-chore")
        app.swipeUp()
        try save("13-edit-chore-bottom")
    }
}
