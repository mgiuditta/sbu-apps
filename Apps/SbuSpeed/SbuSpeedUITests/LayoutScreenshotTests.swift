import XCTest

/// Captures the tool screen in both orientations, at the default and the largest text size,
/// to look at the layouts by hand. Not part of the test run: the scheme skips it, like the App Store screenshots.
final class LayoutScreenshotTests: XCTestCase {
    @MainActor
    private func capture(contentSize: String, name: String) {
        let app = XCUIApplication()
        app.launchArguments += [
            "-AppleLanguages", "(it)", "-AppleLocale", "it_IT", "-FASTLANE_SNAPSHOT", "YES",
            "-UIPreferredContentSizeCategoryName", contentSize,
        ]
        app.launch()
        XCTAssertTrue(app.buttons["Azzera viaggio"].waitForExistence(timeout: 5))

        for orientation in [UIDeviceOrientation.portrait, .landscapeLeft] {
            XCUIDevice.shared.orientation = orientation
            // Let the rotation settle before the screenshot.
            Thread.sleep(forTimeInterval: 1.5)
            let attachment = XCTAttachment(screenshot: XCUIScreen.main.screenshot())
            attachment.name = "\(name)-\(orientation == .portrait ? "portrait" : "landscape")"
            attachment.lifetime = .keepAlways
            add(attachment)
        }
        XCUIDevice.shared.orientation = .portrait
    }

    @MainActor
    func testDefaultText() {
        capture(contentSize: "UICTContentSizeCategoryL", name: "default")
    }

    /// The largest size before the accessibility ones: the screen must still fit without scrolling.
    @MainActor
    func testLargestStandardText() {
        capture(contentSize: "UICTContentSizeCategoryXXXL", name: "xxxl")
    }

    @MainActor
    func testLargestText() {
        capture(contentSize: "UICTContentSizeCategoryAccessibilityXXXL", name: "ax5")
    }
}
