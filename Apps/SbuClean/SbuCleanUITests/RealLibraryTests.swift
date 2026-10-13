import XCTest

/// Opens Sbu Clean on the simulator's real Photos library, seeded with the fixture set:
///
///     python3 Fixtures/make_fixtures.py /tmp/clean-library
///     xcrun simctl addmedia <udid> /tmp/clean-library/*
///     TEST_RUNNER_SBU_CLEAN_REAL_LIBRARY=1 xcodebuild test ... -only-testing:SbuCleanUITests/RealLibraryTests
///
/// Skipped otherwise, since a fresh simulator has an empty library. It grants full access in the
/// system dialog, waits for the scan and leaves screenshots of each screen in the results.
final class RealLibraryTests: XCTestCase {
    override func setUpWithError() throws {
        continueAfterFailure = false
        try XCTSkipUnless(ProcessInfo.processInfo.environment["SBU_CLEAN_REAL_LIBRARY"] == "1", "needs a seeded library")
    }

    @MainActor
    private func attachScreenshot(_ name: String, of app: XCUIApplication) {
        let attachment = XCTAttachment(screenshot: app.screenshot())
        attachment.name = name
        attachment.lifetime = .keepAlways
        add(attachment)
    }

    @MainActor
    private func element(startingWith prefix: String, in app: XCUIApplication) -> XCUIElement {
        app.descendants(matching: .any).matching(NSPredicate(format: "label BEGINSWITH %@", prefix)).firstMatch
    }

    @MainActor
    func testTheSeededLibrary() {
        let app = XCUIApplication()
        app.launchArguments += ["-AppleLanguages", "(it)", "-AppleLocale", "it_IT"]
        app.launch()

        let ask = app.buttons["Consenti l'accesso"]
        if ask.waitForExistence(timeout: 3) {
            ask.tap()
            let springboard = XCUIApplication(bundleIdentifier: "com.apple.springboard")
            let full = springboard.buttons.matching(NSPredicate(format: "label CONTAINS[c] 'complet' OR label CONTAINS[c] 'full' OR label CONTAINS[c] 'tutte'")).firstMatch
            if full.waitForExistence(timeout: 5) {
                full.tap()
            }
        }

        XCTAssertTrue(element(startingWith: "Spazio liberabile", in: app).waitForExistence(timeout: 20))
        let scanned = XCTNSPredicateExpectation(predicate: NSPredicate(format: "label BEGINSWITH 'Spazio liberabile' AND NOT (label CONTAINS 'Cerco') AND NOT (label CONTAINS 'Misuro')"), object: element(startingWith: "Spazio liberabile", in: app))
        XCTAssertEqual(XCTWaiter.wait(for: [scanned], timeout: 120), .completed)
        attachScreenshot("real-01-home", of: app)

        element(startingWith: "Duplicati e simili", in: app).tap()
        attachScreenshot("real-02-duplicates", of: app)
        let duplicates = app.buttons.matching(NSPredicate(format: "label CONTAINS 'gruppi' OR label CONTAINS 'gruppo'")).firstMatch
        if duplicates.waitForExistence(timeout: 5) {
            duplicates.tap()
            attachScreenshot("real-03-groups", of: app)
            app.navigationBars.buttons.element(boundBy: 0).tap()
        }
        let similar = app.buttons.matching(NSPredicate(format: "label CONTAINS 'gruppi' OR label CONTAINS 'gruppo'")).element(boundBy: 1)
        if similar.waitForExistence(timeout: 5) {
            similar.tap()
            attachScreenshot("real-04-similar", of: app)
            app.navigationBars.buttons.element(boundBy: 0).tap()
        }
        app.navigationBars.buttons.element(boundBy: 0).tap()

        element(startingWith: "Screenshot", in: app).tap()
        attachScreenshot("real-05-screenshots", of: app)
        app.navigationBars.buttons.element(boundBy: 0).tap()

        element(startingWith: "Video", in: app).tap()
        attachScreenshot("real-06-videos", of: app)
        let first = app.buttons["Riproduci"].firstMatch
        if first.waitForExistence(timeout: 5) {
            first.tap()
            sleep(2)
            attachScreenshot("real-07-player", of: app)
            app.buttons["Fine"].tap()
        }
        app.navigationBars.buttons.element(boundBy: 0).tap()

        app.buttons["Scorri le foto"].tap()
        attachScreenshot("real-08-months", of: app)
        element(startingWith: "Recenti", in: app).tap()
        sleep(1)
        attachScreenshot("real-09-swipe", of: app)
    }
}
