import XCTest

/// Drives the App Store screenshots for `fastlane snapshot` on the made-up home
/// (`-FASTLANE_SNAPSHOT YES`): today's chores, the rooms, a room, a chore with its history,
/// then the privacy promise in settings.
final class SnapshotTests: XCTestCase {
    @MainActor
    func testScreenshots() {
        let app = XCUIApplication()
        setupSnapshot(app)
        app.launch()

        let chore = app.buttons.matching(identifier: "chore").firstMatch
        XCTAssertTrue(chore.waitForExistence(timeout: 5))
        snapshot("01-today")

        app.buttons["rooms"].tap()
        let room = app.buttons.matching(identifier: "room").element(boundBy: 1)
        XCTAssertTrue(room.waitForExistence(timeout: 5))
        snapshot("02-rooms")

        room.tap()
        XCTAssertTrue(chore.waitForExistence(timeout: 5))
        snapshot("03-room")

        chore.tap()
        XCTAssertTrue(app.buttons["doneNow"].waitForExistence(timeout: 5))
        snapshot("04-chore")

        app.navigationBars.buttons.firstMatch.tap()
        app.navigationBars.buttons.firstMatch.tap()
        app.navigationBars.buttons.firstMatch.tap()
        XCTAssertTrue(app.buttons["rooms"].waitForExistence(timeout: 5))
        app.navigationBars.buttons.element(boundBy: 1).tap()
        // The promises close the settings, under Icona and Suono.
        let sbuDev = app.descendants(matching: .any).matching(NSPredicate(format: "label BEGINSWITH 'Parte di sbu.dev' OR label BEGINSWITH 'Part of sbu.dev'")).firstMatch
        for _ in 0..<6 where !sbuDev.isHittable {
            app.swipeUp()
        }
        snapshot("05-privacy")
    }
}
