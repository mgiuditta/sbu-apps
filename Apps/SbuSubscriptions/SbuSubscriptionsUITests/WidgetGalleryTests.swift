import XCTest

/// Opens the widget gallery from the Home Screen and photographs Sbu Subscriptions' widgets there.
/// The gallery shows the widget's own sample data, never the user's.
final class WidgetGalleryTests: XCTestCase {
    @MainActor
    func testWidgetInGallery() throws {
        let app = XCUIApplication()
        app.launchArguments += ["-FASTLANE_SNAPSHOT", "YES"]
        app.launch()
        XCUIDevice.shared.press(.home)

        let springboard = XCUIApplication(bundleIdentifier: "com.apple.springboard")
        springboard.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5)).press(forDuration: 1.5)
        let edit = springboard.buttons.matching(NSPredicate(format: "label IN %@", ["Edit", "Modifica"])).firstMatch
        if edit.waitForExistence(timeout: 5) { edit.tap() }
        let addWidget = springboard.buttons.matching(NSPredicate(format: "label IN %@", ["Add Widget", "Aggiungi widget"])).firstMatch
        XCTAssertTrue(addWidget.waitForExistence(timeout: 5), springboard.debugDescription)
        addWidget.tap()
        let search = springboard.searchFields.firstMatch
        XCTAssertTrue(search.waitForExistence(timeout: 5))
        search.tap()
        search.typeText("Sbu Subscriptions")
        let result = springboard.descendants(matching: .any).matching(NSPredicate(format: "label CONTAINS %@", "Sbu Subscriptions")).element(boundBy: 1)
        XCTAssertTrue(result.waitForExistence(timeout: 5))
        result.tap()
        sleep(2)
        attach(springboard, "galleria")
        springboard.swipeLeft()
        sleep(1)
        attach(springboard, "galleria-medio")
        springboard.swipeLeft()
        sleep(1)
        attach(springboard, "galleria-grande")
    }

    @MainActor
    private func attach(_ app: XCUIApplication, _ name: String) {
        let attachment = XCTAttachment(screenshot: app.screenshot())
        attachment.name = name
        attachment.lifetime = .keepAlways
        add(attachment)
    }
}
