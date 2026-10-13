import XCTest

/// Visits every screen, sheet, dialog and empty state on the demo library and leaves a
/// screenshot of each in the test results, for the visual review in light and dark, Italian and
/// English, every text size and every iPhone. Navigation goes by accessibility identifier, so
/// it runs in any language. Skipped unless asked:
///
///     TEST_RUNNER_TOUR=1 TEST_RUNNER_TOUR_LANGUAGE=en xcodebuild test ... -only-testing:SbuCleanUITests/ScreenTourTests
final class ScreenTourTests: XCTestCase {
    override func setUpWithError() throws {
        continueAfterFailure = true
        try XCTSkipUnless(ProcessInfo.processInfo.environment["TOUR"] == "1", "a visual review, run on request")
    }

    private var language: String {
        ProcessInfo.processInfo.environment["TOUR_LANGUAGE"] ?? "it"
    }

    @MainActor
    private func launch(access: String = "full") -> XCUIApplication {
        let app = XCUIApplication()
        let locale = language == "en" ? "en_US" : "it_IT"
        app.launchArguments += ["-AppleLanguages", "(\(language))", "-AppleLocale", locale, "-FASTLANE_SNAPSHOT", "YES", "-DemoAccess", access]
        app.launch()
        return app
    }

    @MainActor
    private func shot(_ name: String, _ app: XCUIApplication) {
        sleep(1)
        let attachment = XCTAttachment(screenshot: app.screenshot())
        attachment.name = name
        attachment.lifetime = .keepAlways
        add(attachment)
    }

    @MainActor
    private func tap(_ identifier: String, in app: XCUIApplication) {
        let matches = app.descendants(matching: .any).matching(identifier: identifier)
        func visible() -> XCUIElement? {
            matches.allElementsBoundByIndex.first { $0.exists && $0.isHittable }
        }
        _ = matches.firstMatch.waitForExistence(timeout: 5)
        for _ in 0..<6 where visible() == nil {
            app.swipeUp()
        }
        guard let element = visible() else {
            XCTFail("no \(identifier)")
            return
        }
        element.tap()
    }

    @MainActor
    private func back(_ app: XCUIApplication) {
        app.navigationBars.buttons.element(boundBy: 0).tap()
    }

    @MainActor
    func testPermissions() {
        let ask = launch(access: "notDetermined")
        shot("t01-access", ask)
        ask.terminate()
        let denied = launch(access: "denied")
        shot("t02-denied", denied)
        denied.terminate()
        let limited = launch(access: "limited")
        _ = limited.descendants(matching: .any).matching(identifier: "home.duplicates").firstMatch.waitForExistence(timeout: 10)
        shot("t03-limited", limited)
    }

    @MainActor
    func testEveryScreen() {
        let app = launch()
        _ = app.descendants(matching: .any).matching(identifier: "home.duplicates").firstMatch.waitForExistence(timeout: 10)
        sleep(4)
        shot("t04-home", app)
        app.swipeUp()
        app.swipeUp()
        shot("t05-home-bottom", app)
        app.swipeDown()
        app.swipeDown()

        app.navigationBars.buttons.element(boundBy: 0).tap()
        shot("t06-settings", app)
        app.swipeUp()
        shot("t07-settings-bottom", app)
        app.navigationBars.buttons.element(boundBy: 0).tap()

        tap("pill.months", in: app)
        shot("t08-months", app)
        tap("months.recent", in: app)
        shot("t09-swipe", app)
        let card = app.descendants(matching: .any).matching(identifier: "swipe.card").firstMatch
        if card.waitForExistence(timeout: 5) {
            card.swipeLeft()
            card.press(forDuration: 1)
            shot("t10-details", app)
            app.swipeDown(velocity: .fast)
        }
        back(app)
        tap("months.onThisDay", in: app)
        shot("t11-swipe-empty", app)
        back(app)
        back(app)

        tap("home.duplicates", in: app)
        shot("t12-duplicates", app)
        tap("card.similar", in: app)
        shot("t13-similar", app)
        back(app)
        tap("card.duplicate", in: app)
        shot("t14-groups", app)
        tap("bottomAction", in: app)
        shot("t15-bin", app)
        tap("bottomAction", in: app)
        shot("t16-confirm", app)
        let confirm = app.buttons.matching(NSPredicate(format: "label BEGINSWITH 'Elimina' OR label BEGINSWITH 'Delete'")).allElementsBoundByIndex.last
        confirm?.tap()
        shot("t17-result", app)
        app.navigationBars.buttons.element(boundBy: app.navigationBars.buttons.count - 1).tap()
        shot("t18-bin-empty", app)
        back(app)
        back(app)
        back(app)

        tap("home.grid.screenshots", in: app)
        shot("t19-screenshots", app)
        back(app)
        tap("home.grid.screenRecordings", in: app)
        shot("t20-recordings", app)
        back(app)
        tap("home.videos", in: app)
        shot("t21-videos", app)
        tap("video.play", in: app)
        shot("t22-video-sheet", app)
        app.swipeDown(velocity: .fast)
        let row = app.buttons.matching(NSPredicate(format: "label BEGINSWITH 'Video,'")).firstMatch
        if row.waitForExistence(timeout: 3) {
            row.swipeLeft()
            app.buttons.matching(NSPredicate(format: "label == 'Comprimi' OR label == 'Compress'")).firstMatch.tap()
            shot("t23-compress", app)
            back(app)
        }
        back(app)
        tap("home.livePhotos", in: app)
        shot("t24-live", app)
        back(app)
        tap("home.albums", in: app)
        shot("t25-albums", app)
        back(app)
        tap("home.keepForever", in: app)
        shot("t26-keep", app)
        back(app)
        tap("home.stats", in: app)
        shot("t27-stats", app)
    }
}
