import XCTest

/// Checks on a real iPhone what the simulator can't: the notification permission and a notification arriving.
/// Runs on an empty in-memory store, so the phone's own subscriptions are never touched.
final class DeviceCheckTests: XCTestCase {
    private let springboard = XCUIApplication(bundleIdentifier: "com.apple.springboard")

    @MainActor
    func testPermissionThenTestReminderArrives() throws {
        #if targetEnvironment(simulator)
        throw XCTSkip("Needs a real iPhone: the simulator doesn't show notification banners reliably.")
        #else
        let app = XCUIApplication()
        app.launchArguments += ["-SBU_EMPTY_STORE", "YES", "-SBU_REAL_NOTIFICATIONS", "YES", "-AppleLanguages", "(it)", "-AppleLocale", "it_IT"]
        app.launch()

        // Add one subscription: a reminder is on by default, so iOS asks now and not before.
        app.buttons["addFirst"].tap()
        app.buttons["addCustom"].tap()
        app.textFields["name"].tap()
        app.textFields["name"].typeText("Prova Sbu")
        app.textFields["price"].tap()
        app.textFields["price"].typeText("4,99")
        app.buttons["save"].tap()

        let allow = springboard.alerts.buttons.matching(NSPredicate(format: "label IN %@", ["Consenti", "Allow"])).firstMatch
        if allow.waitForExistence(timeout: 10) {
            attach(springboard, "permesso")
            allow.tap()
        }
        XCTAssertTrue(app.staticTexts["Prova Sbu"].waitForExistence(timeout: 5))

        app.tabBars.buttons["Impostazioni"].tap()
        let send = app.buttons["Invia un promemoria di prova"]
        XCTAssertTrue(send.waitForExistence(timeout: 5), "With permission given, settings offer the test reminder")
        attach(app, "impostazioni")
        send.tap()

        let banner = springboard.descendants(matching: .any).matching(NSPredicate(format: "label CONTAINS %@", "Così arrivano i promemoria")).firstMatch
        XCTAssertTrue(banner.waitForExistence(timeout: 10), "The test reminder shows as a banner")
        attach(springboard, "banner")
        #endif
    }

    @MainActor
    func testLargestTextSizeScreens() {
        let app = XCUIApplication()
        app.launchArguments += ["-FASTLANE_SNAPSHOT", "YES", "-AppleLanguages", "(it)", "-AppleLocale", "it_IT",
                                "-UIPreferredContentSizeCategoryName", "UICTContentSizeCategoryAccessibilityXXXL"]
        app.launch()
        attach(app, "home-ax5")
        app.swipeUp()
        attach(app, "home-ax5-sotto")
        app.swipeUp()
        app.buttons.matching(NSPredicate(format: "label BEGINSWITH %@", "Musica")).firstMatch.tap()
        attach(app, "dettaglio-ax5")
        app.buttons["edit"].tap()
        attach(app, "modifica-ax5")
        app.buttons["Annulla"].tap()
        // The detail is a sheet: dragged down from its top edge.
        app.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.08))
            .press(forDuration: 0.1, thenDragTo: app.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.98)))
        app.swipeDown()
        app.swipeDown()
        app.tabBars.buttons["Impostazioni"].tap()
        attach(app, "impostazioni-ax5")
    }

    @MainActor
    private func attach(_ app: XCUIApplication, _ name: String) {
        let attachment = XCTAttachment(screenshot: app.screenshot())
        attachment.name = name
        attachment.lifetime = .keepAlways
        add(attachment)
    }
}
