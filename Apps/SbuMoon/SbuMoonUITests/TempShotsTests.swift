import XCTest

/// Temporary: walks every screen and state for the QA screenshots. Not committed.
final class TempShotsTests: XCTestCase {
    private var english: Bool { ProcessInfo.processInfo.environment["SHOT_LANG"] == "en" }

    private func t(_ it: String, _ en: String) -> String { english ? en : it }

    @MainActor
    private func shot(_ app: XCUIApplication, _ name: String) {
        sleep(1)
        let attachment = XCTAttachment(screenshot: XCUIScreen.main.screenshot())
        attachment.name = name
        attachment.lifetime = .keepAlways
        add(attachment)
    }

    @MainActor
    private func answerSystemAlert(prefix: String) {
        let springboard = XCUIApplication(bundleIdentifier: "com.apple.springboard")
        let alert = springboard.alerts.firstMatch
        if alert.waitForExistence(timeout: 5) {
            let button = alert.buttons.matching(NSPredicate(format: "label BEGINSWITH %@", prefix)).firstMatch
            if button.exists { button.tap() } else { alert.buttons.firstMatch.tap() }
        }
    }

    @MainActor
    func testShots() {
        continueAfterFailure = true
        let app = XCUIApplication()
        app.launchArguments += english
            ? ["-AppleLanguages", "(en)", "-AppleLocale", "en_US"]
            : ["-AppleLanguages", "(it)", "-AppleLocale", "it_IT"]
        app.launch()
        _ = app.buttons["date"].waitForExistence(timeout: 10)
        shot(app, "01-main-empty")
        app.swipeUp()
        shot(app, "02-main-empty-scrolled")
        app.swipeDown()
        app.swipeDown()

        app.buttons["date"].tap()
        shot(app, "03-date-sheet")
        app.navigationBars.buttons[t("Fine", "Done")].tap()

        let place = app.buttons["place"]
        if !place.isHittable { app.swipeUp() }
        place.tap()
        _ = app.searchFields.firstMatch.waitForExistence(timeout: 5)
        shot(app, "04-place-sheet")
        app.searchFields.firstMatch.tap()
        app.searchFields.firstMatch.typeText("xyz")
        shot(app, "05-place-no-results")
        app.searchFields.firstMatch.buttons.firstMatch.tap() // clear
        let cancel = app.buttons[t("Annulla", "Cancel")]
        if cancel.exists { cancel.tap() }

        app.buttons["useCurrentLocation"].tap()
        sleep(2)
        shot(app, "06-location-prompt")
        answerSystemAlert(prefix: "Don")
        _ = app.buttons[t("Apri Impostazioni", "Open Settings")].waitForExistence(timeout: 15)
        shot(app, "07-place-location-denied")

        app.searchFields.firstMatch.tap()
        app.searchFields.firstMatch.typeText("New York")
        app.buttons["New York"].firstMatch.tap()
        sleep(1)
        shot(app, "08-main-new-york")
        app.swipeUp()
        shot(app, "09-main-new-york-scrolled")
        app.swipeDown()
        app.swipeDown()

        app.buttons["place"].tap()
        app.searchFields.firstMatch.tap()
        app.searchFields.firstMatch.typeText("Reykj")
        app.buttons.matching(NSPredicate(format: "label BEGINSWITH 'Reykj'")).firstMatch.tap()
        sleep(1)
        shot(app, "10-main-reykjavik")

        app.buttons[t("Impostazioni", "Settings")].tap()
        sleep(1)
        shot(app, "11-settings")
        app.switches[t("Luna piena", "Full moon")].switches.firstMatch.tap()
        sleep(2)
        shot(app, "12-notification-prompt")
        answerSystemAlert(prefix: "Don")
        sleep(2)
        shot(app, "13-settings-notifications-denied")
        app.swipeUp()
        shot(app, "14-settings-scrolled")
        app.swipeUp()
        shot(app, "15-settings-bottom")
    }

    @MainActor
    func testDenyLocation() {
        let app = XCUIApplication()
        app.launchArguments += ["-AppleLanguages", "(it)", "-AppleLocale", "it_IT"]
        app.launch()
        app.buttons["place"].tap()
        app.buttons["useCurrentLocation"].tap()
        answerSystemAlert(prefix: "Don")
        XCTAssertTrue(app.buttons["Apri Impostazioni"].waitForExistence(timeout: 15))
        shot(app, "deny")
    }
}
