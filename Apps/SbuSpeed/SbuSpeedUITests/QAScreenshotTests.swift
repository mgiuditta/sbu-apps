import XCTest

/// Walks every screen and state of the app and saves a screenshot of each, with the accessibility tree,
/// for the review before a release. Not part of the test run: the scheme skips it.
///
/// Set by the script that runs it, through `TEST_RUNNER_` variables: `QA_LANG` (`it` or `en`) and
/// `QA_SIZE` (a content size category). `testPermissionFlow` needs the location access reset before,
/// `testScreens` needs it granted.
final class QAScreenshotTests: XCTestCase {
    private var language: String { ProcessInfo.processInfo.environment["QA_LANG"] ?? "it" }
    private var contentSize: String { ProcessInfo.processInfo.environment["QA_SIZE"] ?? "UICTContentSizeCategoryL" }
    private var isItalian: Bool { language == "it" }

    override func setUp() {
        continueAfterFailure = true
        XCUIDevice.shared.orientation = .portrait
    }

    @MainActor
    private func launch(_ arguments: [String] = []) -> XCUIApplication {
        let app = XCUIApplication()
        app.launchArguments += [
            "-AppleLanguages", "(\(language))", "-AppleLocale", isItalian ? "it_IT" : "en_US",
            "-UIPreferredContentSizeCategoryName", contentSize,
            // Every launch starts from the region's unit and no limit, whatever the last run chose.
            "-unit", isItalian ? "kilometersPerHour" : "milesPerHour", "-speedLimit", "",
        ] + arguments
        app.launch()
        return app
    }

    @MainActor
    private func capture(_ name: String, _ app: XCUIApplication) {
        Thread.sleep(forTimeInterval: 1.2)
        let shot = XCTAttachment(screenshot: XCUIScreen.main.screenshot())
        shot.name = name
        shot.lifetime = .keepAlways
        add(shot)
        let tree = XCTAttachment(string: app.debugDescription)
        tree.name = "\(name)-tree"
        tree.lifetime = .keepAlways
        add(tree)
    }

    @MainActor
    func testPermissionFlow() {
        let app = launch(["-trip", ""])
        let springboard = XCUIApplication(bundleIdentifier: "com.apple.springboard")
        let alert = springboard.alerts.firstMatch
        if alert.waitForExistence(timeout: 5) {
            capture("01-permission-prompt", app)
            let refuse = alert.buttons.element(boundBy: alert.buttons.count - 1)
            alert.buttons.allElementsBoundByIndex.first { ["Non consentire", "Don’t Allow", "Don't Allow"].contains($0.label) }?.tap() ?? refuse.tap()
        }
        capture("02-denied", app)
        XCUIDevice.shared.orientation = .landscapeLeft
        capture("03-denied-landscape", app)
    }

    @MainActor
    func testScreens() {
        // Granted, with no fix and an empty trip: the first launch outdoors.
        var app = launch(["-trip", ""])
        capture("10-searching-empty", app)
        app.terminate()

        // The fixed drive.
        app = launch(["-FASTLANE_SNAPSHOT", "YES"])
        capture("11-main", app)
        XCUIDevice.shared.orientation = .landscapeLeft
        capture("12-main-landscape", app)
        XCUIDevice.shared.orientation = .portrait

        let reset = app.buttons[isItalian ? "Salva e azzera" : "Save and reset"]
        if reset.waitForExistence(timeout: 3) {
            reset.tap()
            capture("13-reset-confirm", app)
        }
        // A fresh launch, so no dialog is left in the way.
        app.terminate()
        app = launch(["-FASTLANE_SNAPSHOT", "YES"])

        app.buttons[isItalian ? "Parabrezza" : "HUD"].tap()
        capture("20-hud", app)
        app.buttons[isItalian ? "Esci dal parabrezza" : "Exit HUD"].tap()

        app.buttons[isItalian ? "Viaggi" : "Trips"].tap()
        capture("21-trips", app)
        app.buttons.matching(identifier: "trip").firstMatch.tap()
        capture("22-trip-detail", app)
        app.navigationBars.buttons.firstMatch.tap()
        app.navigationBars.buttons.firstMatch.tap()

        app.buttons[isItalian ? "Impostazioni" : "Settings"].tap()
        _ = app.buttons[isItalian ? "Fine" : "Done"].waitForExistence(timeout: 3)
        capture("14-settings", app)
        app.swipeUp()
        capture("15-settings-bottom", app)
        app.swipeDown()

        app.buttons[isItalian ? "Nodi" : "Knots"].tap()
        let limit = app.buttons.matching(NSPredicate(format: "label BEGINSWITH %@", isItalian ? "Limite" : "Limit")).firstMatch
        if limit.waitForExistence(timeout: 3) {
            limit.tap()
            capture("16-limit-menu-knots", app)
            app.buttons.matching(NSPredicate(format: "label BEGINSWITH '20'")).firstMatch.tap()
        }
        capture("17-settings-knots", app)
        let done = app.buttons[isItalian ? "Fine" : "Done"]
        if done.waitForExistence(timeout: 3) {
            done.tap()
        } else {
            app.swipeDown(velocity: .fast)
        }
        // 52 km/h is 28 kn: over the 20 kn limit.
        capture("18-main-knots-over-limit", app)
        app.buttons[isItalian ? "Parabrezza" : "HUD"].tap()
        capture("23-hud-over-limit", app)
        app.buttons[isItalian ? "Esci dal parabrezza" : "Exit HUD"].tap()
        XCUIDevice.shared.orientation = .landscapeLeft
        capture("19-over-limit-landscape", app)
        XCUIDevice.shared.orientation = .portrait
    }
}
