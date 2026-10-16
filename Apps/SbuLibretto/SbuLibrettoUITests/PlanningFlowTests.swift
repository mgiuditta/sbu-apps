import XCTest

/// On the sample libretto: the sittings with their countdown and the weekly timetable, audited.
final class PlanningFlowTests: LibrettoUITestCase {
    @MainActor
    func testTheNextSittingCountsDown() throws {
        let app = launch(sample: true)
        let upcoming = app.buttons["upcoming"]
        XCTAssertTrue(upcoming.waitForExistence(timeout: 5))
        // The sample's next sitting is in 12 days.
        XCTAssertTrue(upcoming.label.contains("Tra 12 giorni"), upcoming.label)
        upcoming.tap()
        XCTAssertTrue(app.navigationBars["Prossimi appelli"].waitForExistence(timeout: 5))
        let first = app.buttons["Sistemi operativi"]
        XCTAssertTrue(first.waitForExistence(timeout: 5))
        XCTAssertTrue((first.value as? String ?? "").hasPrefix("Tra 12 giorni"), first.debugDescription)
        XCTAssertTrue(app.buttons["Ingegneria del software"].exists)
        attach(app, "prossimi appelli")
        try audit(app)
    }

    @MainActor
    func testALessonKeepsItsTimeInTwentyFourHours() throws {
        let app = launch(sample: true)
        let timetable = app.buttons["timetable"]
        XCTAssertTrue(timetable.waitForExistence(timeout: 5))
        timetable.tap()
        XCTAssertTrue(app.navigationBars["Orario lezioni"].waitForExistence(timeout: 5))
        attach(app, "orario")
        try audit(app)

        app.buttons["addLesson"].tap()
        type("Statistica", into: app.textFields["lessonTitle"])
        attach(app, "nuova lezione")
        try audit(app)
        app.buttons["saveLesson"].tap()

        let lesson = app.buttons["Statistica"]
        XCTAssertTrue(lesson.waitForExistence(timeout: 5))
        XCTAssertEqual(lesson.value as? String, "dalle 09:00 alle 11:00")
    }

    @MainActor
    func testTimetableInEnglishHasNoAMPM() throws {
        let app = launch(sample: true, language: "en", locale: "en_US")
        let timetable = app.buttons["timetable"]
        XCTAssertTrue(timetable.waitForExistence(timeout: 5))
        timetable.tap()
        app.buttons["addLesson"].tap()
        type("Statistics", into: app.textFields["lessonTitle"])
        app.buttons["saveLesson"].tap()
        let lesson = app.buttons["Statistics"]
        XCTAssertTrue(lesson.waitForExistence(timeout: 5))
        XCTAssertEqual(lesson.value as? String, "from 09:00 to 11:00")
        attach(app, "timetable en_US")
        try audit(app)
    }
}
