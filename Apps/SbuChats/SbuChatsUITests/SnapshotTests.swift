import XCTest

/// Drives the App Store screenshots for `fastlane snapshot`, on the made-up sample chat:
/// the chat's figure, the activity, the words, the search, then the privacy promise in settings.
final class SnapshotTests: XCTestCase {
    @MainActor
    func testScreenshots() {
        let app = XCUIApplication()
        setupSnapshot(app)
        app.launchArguments += ["-SEED_SAMPLE", "YES"]
        app.launch()

        // The first chat's link: the title above the list is a cell too.
        let row = app.collectionViews.buttons.firstMatch
        XCTAssertTrue(row.waitForExistence(timeout: 20))
        row.tap()
        sleep(1)
        snapshot("01-chat")

        open("activity", in: app)
        sleep(1)
        snapshot("02-activity")
        app.navigationBars.buttons.element(boundBy: 0).tap()

        open("words", in: app)
        sleep(1)
        snapshot("03-words")
        app.navigationBars.buttons.element(boundBy: 0).tap()
        app.navigationBars.buttons.element(boundBy: 0).tap()

        snapshot("04-chats")

        app.navigationBars.buttons.element(boundBy: 1).tap()
        snapshot("05-privacy")
    }

    /// Scrolls to a row of the chat screen by its identifier and opens it.
    @MainActor
    private func open(_ identifier: String, in app: XCUIApplication) {
        let row = app.buttons[identifier]
        for _ in 0 ..< 16 where !(row.exists && row.isHittable) {
            // From low on the screen: the figure stays above the rows and doesn't scroll.
            app.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.9))
                .press(forDuration: 0.05, thenDragTo: app.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.7)))
        }
        row.tap()
    }
}
