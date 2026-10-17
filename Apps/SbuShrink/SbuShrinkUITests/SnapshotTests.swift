import XCTest

/// Drives the App Store screenshots for `fastlane snapshot`, on the demo that `-FASTLANE_SNAPSHOT`
/// opens with five picked videos: the settings with the estimate, the run halfway, the result
/// with the savings, then the privacy promise in settings.
final class SnapshotTests: XCTestCase {
    @MainActor
    func testScreenshots() {
        let app = XCUIApplication()
        setupSnapshot(app)
        app.launchArguments += ["-DemoVideos", "5", "-DemoSpeed", "slow"]
        app.launch()

        let estimate = app.descendants(matching: .any).matching(NSPredicate(format: "label BEGINSWITH 'Dimensione stimata' OR label BEGINSWITH 'Estimated size'")).firstMatch
        XCTAssertTrue(estimate.waitForExistence(timeout: 10))
        sleep(1)
        snapshot("01-settings")

        app.buttons.matching(NSPredicate(format: "label == 'Comprimi' OR label == 'Compress'")).firstMatch.tap()
        // Halfway through the second video, as in the original's screenshot.
        sleep(6)
        snapshot("02-compressing")

        let keep = app.buttons.matching(NSPredicate(format: "label BEGINSWITH 'Tieni' OR label BEGINSWITH 'Keep'")).firstMatch
        XCTAssertTrue(keep.waitForExistence(timeout: 40))
        sleep(1)
        snapshot("03-done")

        keep.tap()
        let gear = app.navigationBars.buttons.element(boundBy: 0)
        XCTAssertTrue(gear.waitForExistence(timeout: 5))
        gear.tap()
        sleep(1)
        // The promises close the settings, under Icona and Suono.
        let sbuDev = app.descendants(matching: .any).matching(NSPredicate(format: "label BEGINSWITH 'Parte di sbu.dev' OR label BEGINSWITH 'Part of sbu.dev'")).firstMatch
        for _ in 0..<6 where !sbuDev.isHittable {
            app.swipeUp()
        }
        snapshot("04-privacy")
    }
}
