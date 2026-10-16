import XCTest

/// Drives the list, the finder, help and settings with the fixed scanner, and runs the
/// accessibility audit on each. Runs in Italian; the simulator has no Bluetooth.
final class FindFlowTests: XCTestCase {
    override func setUp() {
        continueAfterFailure = false
    }

    /// Contrast is left out as in the other apps: text colors come from tokens with checked
    /// ratios, and the audit misreads the iOS 26 glass bar.
    private static let screenExclusions: XCUIAccessibilityAuditType = [.contrast]
    /// Sheets also leave out Dynamic Type and clipped text: the audit flags the system buttons
    /// in the iOS 26 glass toolbar of a sheet, as in the other apps.
    private static let sheetExclusions: XCUIAccessibilityAuditType = [.contrast, .dynamicType, .textClipped]

    @MainActor
    private func launch(scanner: String = "demo", _ arguments: [String] = []) -> XCUIApplication {
        let app = XCUIApplication()
        app.launchArguments += ["-AppleLanguages", "(it)", "-AppleLocale", "it_IT", "-FIXED_SCANNER", scanner]
        // Arguments win over saved settings: every test starts from the defaults.
        app.launchArguments += ["-showsUnnamed", "NO", "-playsSound", "NO", "-vibrates", "NO"]
        app.launchArguments += arguments
        app.launch()
        return app
    }

    @MainActor
    private func audit(_ app: XCUIApplication, excluding excluded: XCUIAccessibilityAuditType = screenExclusions) throws {
        try app.performAccessibilityAudit(for: XCUIAccessibilityAuditType.all.subtracting(excluded)) { issue in
            XCTFail("\(issue.compactDescription):\(issue.element?.debugDescription ?? "no element")")
            return true
        }
    }

    @MainActor
    func testDeniedBluetoothSaysSoAndOffersSettings() throws {
        let app = launch(scanner: "denied")
        XCTAssertTrue(app.staticTexts["Bluetooth non consentito"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.buttons["Apri Impostazioni"].exists)
        try audit(app)
    }

    @MainActor
    func testBluetoothOffSaysHowToTurnItOnWithoutASettingsButton() throws {
        let app = launch(scanner: "poweredOff")
        XCTAssertTrue(app.staticTexts["Bluetooth spento"].waitForExistence(timeout: 5))
        XCTAssertFalse(app.buttons["Apri Impostazioni"].exists)
        try audit(app)
    }

    @MainActor
    func testUnsupportedSaysTheDeviceCannotScan() throws {
        let app = launch(scanner: "unsupported")
        XCTAssertTrue(app.staticTexts["Bluetooth non disponibile"].waitForExistence(timeout: 5))
        try audit(app)
    }
}
