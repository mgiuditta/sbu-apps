import CoreLocation
import XCTest

/// Drives the real location path with simulated fixes that carry a speed, which `simctl location` does not.
/// Not part of the test run: it needs location access, which a fresh simulator asks for. The scheme skips it.
final class SimulatedDriveTests: XCTestCase {
    override func setUp() {
        continueAfterFailure = false
    }

    /// A fix `seconds` into the drive, `metersNorth` of the start, going north at `speed` m/s.
    private func fix(at seconds: TimeInterval, metersNorth: Double, speed: Double, start: Date) -> XCUILocation {
        // About 111 km per degree of latitude.
        let coordinate = CLLocationCoordinate2D(latitude: 45.4642 + metersNorth / 111_000, longitude: 9.19)
        let location = CLLocation(
            coordinate: coordinate,
            altitude: 120,
            horizontalAccuracy: 5,
            verticalAccuracy: 5,
            course: 0,
            courseAccuracy: 5,
            speed: speed,
            speedAccuracy: 0.5,
            timestamp: start.addingTimeInterval(seconds)
        )
        return XCUILocation(location: location)
    }

    @MainActor
    func testDriveShowsSpeedAndTripInKnots() throws {
        let app = XCUIApplication()
        // Fresh settings: the unit follows the region, and the screen starts from an empty trip.
        app.launchArguments += ["-AppleLanguages", "(it)", "-AppleLocale", "it_IT", "-unit", "knots", "-trip", ""]
        app.launch()

        let springboard = XCUIApplication(bundleIdentifier: "com.apple.springboard")
        let allow = springboard.buttons["Consenti mentre usi l'app"]
        if allow.waitForExistence(timeout: 3) {
            allow.tap()
        }

        // 10.29 m/s is 20 kn; one fix a second for 20 seconds: 205.8 m, 0.1 nmi.
        let start = Date()
        var metersNorth = 0.0
        for second in 0...20 {
            XCUIDevice.shared.location = fix(at: TimeInterval(second), metersNorth: metersNorth, speed: 10.29, start: start)
            metersNorth += 10.29
            Thread.sleep(forTimeInterval: 1)
        }

        let figure = app.staticTexts.matching(NSPredicate(format: "label BEGINSWITH 'SOG'")).firstMatch
        XCTAssertTrue(figure.waitForExistence(timeout: 5))
        XCTAssertTrue(figure.label.contains("20"), figure.label)
        XCTAssertTrue(figure.label.contains("kn"), figure.label)
        let top = app.descendants(matching: .any)["Massima"]
        XCTAssertEqual(top.value as? String, "20 kn")
        let distance = (app.descendants(matching: .any)["Distanza"].value as? String)?.replacingOccurrences(of: "\u{00A0}", with: " ")
        XCTAssertEqual(distance, "0,1 nmi")
        XCTAssertEqual(app.descendants(matching: .any)["Durata"].value as? String, "20 secondi")

        let attachment = XCTAttachment(screenshot: XCUIScreen.main.screenshot())
        attachment.name = "drive-knots"
        attachment.lifetime = .keepAlways
        add(attachment)
    }
}
