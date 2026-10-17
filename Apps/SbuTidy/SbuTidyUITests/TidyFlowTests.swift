import XCTest

/// Drives Tody's flows on an empty store: first run, rooms, a room, a new chore from the
/// suggestions, done now, done on a day, pause, history; with the accessibility audit on each screen.
final class TidyFlowTests: TidyUITestCase {
    @MainActor
    func testFirstRunOffersTheBaseRoomsAndPassesTheAudit() throws {
        let app = launch()
        XCTAssertTrue(app.buttons["addBaseRooms"].waitForExistence(timeout: 5))
        try audit(app)

        addBaseRooms(app)
        // Base chores start just done: nothing to do and nothing done, so the empty state says so.
        let empty = app.staticTexts.matching(NSPredicate(format: "label BEGINSWITH 'Niente da fare oggi'")).firstMatch
        XCTAssertTrue(empty.waitForExistence(timeout: 5))
        XCTAssertFalse(app.switches.matching(identifier: "todayChore").firstMatch.exists)
        try audit(app)
    }

    @MainActor
    func testRoomsListDuplicatesAndPassesTheAudit() throws {
        let app = launch()
        addBaseRooms(app)
        app.buttons["rooms"].tap()
        let rooms = app.buttons.matching(identifier: "room")
        XCTAssertTrue(rooms.firstMatch.waitForExistence(timeout: 5))
        XCTAssertEqual(rooms.count, 4)
        XCTAssertTrue(rooms.element(boundBy: 0).label.hasPrefix("Cucina"), rooms.element(boundBy: 0).label)
        try audit(app)

        rooms.element(boundBy: 1).swipeLeft()
        app.buttons["Duplica"].tap()
        XCTAssertEqual(rooms.count, 5)
        XCTAssertTrue(rooms.element(boundBy: 2).label.hasPrefix("Bagno 2"), rooms.element(boundBy: 2).label)
    }

    @MainActor
    func testAddAChoreFromTheSuggestionsMarkItDoneAndSeeTheHistory() throws {
        let app = launch()
        addBaseRooms(app)
        app.buttons["rooms"].tap()
        let kitchen = app.buttons.matching(identifier: "room").firstMatch
        XCTAssertTrue(kitchen.waitForExistence(timeout: 5))
        kitchen.tap()
        try audit(app)

        app.buttons["addChore"].tap()
        app.buttons["presets"].tap()
        try audit(app)
        app.buttons.matching(NSPredicate(format: "label BEGINSWITH 'Pulire il forno'")).firstMatch.tap()
        let name = app.textFields["choreName"]
        XCTAssertTrue(name.waitForExistence(timeout: 5))
        XCTAssertEqual(name.value as? String, "Pulire il forno")
        app.buttons["saveChore"].tap()

        let oven = app.buttons.matching(NSPredicate(format: "identifier == 'chore' AND label BEGINSWITH 'Pulire il forno'")).firstMatch
        XCTAssertTrue(scroll(app, to: oven))
        oven.tap()
        let figure = figureElement(app, "choreFigure")
        XCTAssertTrue(figure.waitForExistence(timeout: 5))
        try audit(app)

        app.buttons["doneNow"].tap()
        app.swipeUp()
        XCTAssertTrue(app.staticTexts.matching(identifier: "historyEntry").firstMatch.waitForExistence(timeout: 5))
        XCTAssertEqual(app.staticTexts.matching(identifier: "historyEntry").count, 1)

        app.buttons["pause"].tap()
        XCTAssertTrue(app.buttons["Riprendi"].waitForExistence(timeout: 5))
        XCTAssertTrue(figure.label.contains("In pausa"), figure.label)
        app.buttons["Riprendi"].tap()
        XCTAssertTrue(app.buttons["Metti in pausa"].waitForExistence(timeout: 5))
    }

    @MainActor
    func testANewChoreStartsCleanAWeekAway() throws {
        let app = launch()
        addBaseRooms(app)
        app.buttons["rooms"].tap()
        app.buttons.matching(identifier: "room").element(boundBy: 1).tap()
        app.buttons["addChore"].tap()
        let name = app.textFields["choreName"]
        XCTAssertTrue(name.waitForExistence(timeout: 5))
        try audit(app)
        name.tap()
        name.typeText("Lavare il tappetino")
        // Weekly by default, last done today: due in a week.
        app.buttons["saveChore"].tap()

        let chore = app.buttons.matching(NSPredicate(format: "identifier == 'chore' AND label BEGINSWITH 'Lavare il tappetino'")).firstMatch
        XCTAssertTrue(scroll(app, to: chore))
        XCTAssertTrue(chore.label.contains("Tra 7 giorni"), chore.label)
    }

    @MainActor
    func testDoneOnADayGoesInTheHistory() throws {
        let app = launch()
        addBaseRooms(app)
        app.buttons["rooms"].tap()
        app.buttons.matching(identifier: "room").firstMatch.tap()
        let first = app.buttons.matching(identifier: "chore").firstMatch
        XCTAssertTrue(first.waitForExistence(timeout: 5))
        first.tap()
        app.buttons["doneOn"].tap()
        XCTAssertTrue(app.buttons["confirmDoneOn"].waitForExistence(timeout: 5))
        app.buttons["confirmDoneOn"].tap()
        app.swipeUp()
        XCTAssertTrue(app.staticTexts.matching(identifier: "historyEntry").firstMatch.waitForExistence(timeout: 5))
    }

    @MainActor
    func testTheBoxMarksTheDirtiestChoreDoneAndTheFigureDrops() throws {
        let app = launch(["-FASTLANE_SNAPSHOT", "YES"])
        let figure = figureElement(app, "todayFigure")
        XCTAssertTrue(figure.waitForExistence(timeout: 5))
        let before = figure.label
        try audit(app)

        let first = app.switches.matching(NSPredicate(format: "identifier == 'todayChore' AND value == '0'")).firstMatch
        XCTAssertTrue(first.exists)
        let name = first.label
        first.tap()
        XCTAssertTrue(figure.waitForExistence(timeout: 5))
        XCTAssertNotEqual(figure.label, before)
        // Ticked, the chore stays in the list, done, after the ones still to do.
        let chore = String(name.prefix { $0 != "," })
        let done = app.switches.matching(NSPredicate(format: "identifier == 'todayChore' AND label BEGINSWITH %@", chore)).firstMatch
        XCTAssertTrue(scroll(app, to: done))
        XCTAssertEqual(done.value as? String, "1")
        XCTAssertTrue(done.label.contains("Fatta oggi"), done.label)

        // Taken back, the figure is as before.
        done.tap()
        XCTAssertTrue(figure.waitForExistence(timeout: 5))
        XCTAssertEqual(figure.label, before)

        app.buttons["In scadenza"].tap()
        let upcoming = app.switches.matching(NSPredicate(format: "identifier == 'todayChore' AND (label CONTAINS 'Tra ' OR label CONTAINS 'Domani')")).firstMatch
        XCTAssertTrue(upcoming.waitForExistence(timeout: 5))
        XCTAssertFalse(app.switches.matching(NSPredicate(format: "identifier == 'todayChore' AND label CONTAINS 'ritardo'")).firstMatch.exists)
        try audit(app)
    }

    @MainActor
    func testTheToolScreenPassesTheAuditAtTheLargestTextSize() throws {
        let app = launch(["-FASTLANE_SNAPSHOT", "YES", "-UIPreferredContentSizeCategoryName", "UICTContentSizeCategoryAccessibilityXXXL"])
        let figure = figureElement(app, "todayFigure")
        XCTAssertTrue(figure.waitForExistence(timeout: 5))
        try audit(app)
    }

    @MainActor
    func testSettingsOfferRemindersOffByDefault() throws {
        let app = launch()
        addBaseRooms(app)
        app.navigationBars.buttons.element(boundBy: 1).tap()
        let toggle = app.switches["remindersToggle"]
        XCTAssertTrue(scroll(app, to: toggle))
        XCTAssertEqual(toggle.value as? String, "0")
        toggle.tap()
        XCTAssertTrue(app.datePickers.firstMatch.waitForExistence(timeout: 5))
        try audit(app)
    }
}
