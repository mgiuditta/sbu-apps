import XCTest

/// Drives Ricalca in each camera state the simulator can show, with the audit. The simulator has
/// no camera: the other states are forced with `-CAMERA_ACCESS`.
final class TraceFlowTests: XCTestCase {
    override func setUp() {
        continueAfterFailure = false
    }

    @MainActor
    private func openTrace(access: String?) -> XCUIApplication {
        let app = GridFlowTests.launch(photo: "demo", access.map { ["-CAMERA_ACCESS", $0] } ?? [])
        let trace = app.buttons["Ricalca"]
        XCTAssertTrue(trace.waitForExistence(timeout: 5))
        trace.tap()
        return app
    }

    @MainActor
    func testTheFirstTimeItExplainsTheCameraBeforeAsking() throws {
        let app = openTrace(access: "notDetermined")
        XCTAssertTrue(app.staticTexts["Ricalca sulla carta"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.buttons["Usa la fotocamera"].exists)
        XCTAssertTrue(app.buttons["Chiudi"].exists)
        try GridFlowTests.audit(app)
        app.buttons["Chiudi"].tap()
        XCTAssertTrue(app.buttons["Ricalca"].waitForExistence(timeout: 5))
    }

    @MainActor
    func testARefusedCameraOffersSettings() throws {
        let app = openTrace(access: "denied")
        XCTAssertTrue(app.staticTexts["Fotocamera non consentita"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.buttons["Apri Impostazioni"].exists)
        try GridFlowTests.audit(app)
    }

    @MainActor
    func testWithoutACameraItSaysSo() throws {
        // The simulator itself has no rear camera.
        let app = openTrace(access: nil)
        XCTAssertTrue(app.staticTexts["Fotocamera non disponibile"].waitForExistence(timeout: 5))
        XCTAssertFalse(app.buttons["Apri Impostazioni"].exists)
        try GridFlowTests.audit(app)
    }
}
