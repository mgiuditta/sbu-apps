import XCTest

/// Shares a Statistiche page like a person would: Condividi opens the system share sheet with
/// the page as a picture. Runs in Italian on a throwaway file.
final class StatisticsShareFlowTests: XCTestCase {
    private let file = "uitest-\(UUID().uuidString).json"

    override func setUp() {
        continueAfterFailure = false
    }

    @MainActor
    private func launch() -> XCUIApplication {
        let app = XCUIApplication()
        app.launchArguments += ["-AppleLanguages", "(it)", "-AppleLocale", "it_IT"]
        app.launchEnvironment["SBU_HABITS_FILE"] = file
        app.launch()
        return app
    }

    @MainActor
    func testCondividiOpensTheShareSheetWithThePageOnShow() throws {
        let app = launch()
        app.openHabitForm()
        app.typeTitleAndAdd("Leggere")

        app.buttons["Statistiche"].tap()
        XCTAssertTrue(app.staticTexts["Tutte le abitudini"].waitForExistence(timeout: 5))
        app.buttons["statistics-Leggere"].tap()
        expectValue(app.descendants(matching: .any)["statistics-pages"], "2 di 2")

        let share = app.buttons["Condividi"]
        XCTAssertTrue(share.isHittable)
        try app.performAccessibilityAudit(for: XCUIAccessibilityAuditType.all.subtracting([.contrast, .dynamicType])) { issue in
            XCTFail("\(issue.compactDescription): \(issue.element?.debugDescription ?? issue.detailedDescription)")
            return true
        }

        share.tap()
        XCTAssertTrue(app.otherElements["ActivityListView"].waitForExistence(timeout: 10), app.debugDescription)
        // The share sheet's header names the page and the period chosen.
        XCTAssertTrue(app.navigationBars["Sbu Habits · Leggere · Dall'inizio"].waitForExistence(timeout: 5), app.debugDescription)

        let screenshot = XCTAttachment(screenshot: app.screenshot())
        screenshot.name = "share-sheet"
        screenshot.lifetime = .keepAlways
        add(screenshot)
    }

    /// Waits for VoiceOver's value to settle: the screen updates a moment after the tap.
    @MainActor
    private func expectValue(_ element: XCUIElement, _ value: String, file: StaticString = #filePath, line: UInt = #line) {
        let settled = XCTNSPredicateExpectation(predicate: NSPredicate(format: "value == %@", value), object: element)
        let result = XCTWaiter.wait(for: [settled], timeout: 5)
        XCTAssertEqual(result, .completed, "value is \(element.value ?? "nil")", file: file, line: line)
    }
}
