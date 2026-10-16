import XCTest

/// Drives Tody's flows on an empty store: first run, rooms, a room, a new chore from the
/// suggestions, done now, done on a day, pause, history; with the accessibility audit on each screen.
final class TidyFlowTests: TidyUITestCase {
    @MainActor
    func testFirstRunOffersTheBaseRoomsAndPassesTheAudit() throws {
        let app = launch()
        XCTAssertTrue(app.buttons["addBaseRooms"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.buttons["addFirstRoom"].exists)
        try audit(app)

        addBaseRooms(app)
        let figure = app.staticTexts.matching(NSPredicate(format: "label BEGINSWITH 'Da fare oggi'")).firstMatch
        XCTAssertTrue(figure.waitForExistence(timeout: 5))
        // Base chores start just done: nothing to do, and the list says so.
        XCTAssertTrue(figure.label.contains("0"), figure.label)
        XCTAssertTrue(app.staticTexts["Niente da fare oggi"].exists)
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
        let figure = app.staticTexts.matching(NSPredicate(format: "label BEGINSWITH 'Giorni alla scadenza'")).firstMatch
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
    func testSwipeMarksTheDirtiestChoreDoneAndTheFigureDrops() throws {
        let app = launch(["-FASTLANE_SNAPSHOT", "YES"])
        let figure = app.staticTexts.matching(NSPredicate(format: "label BEGINSWITH 'Da fare oggi'")).firstMatch
        XCTAssertTrue(figure.waitForExistence(timeout: 5))
        let before = figure.label
        try audit(app)

        let first = app.buttons.matching(identifier: "chore").firstMatch
        let name = first.label
        first.swipeRight()
        app.buttons["Fatta"].firstMatch.tap()
        let after = app.staticTexts.matching(NSPredicate(format: "label BEGINSWITH 'Da fare oggi'")).firstMatch
        XCTAssertTrue(after.waitForExistence(timeout: 5))
        XCTAssertNotEqual(after.label, before)
        XCTAssertNotEqual(app.buttons.matching(identifier: "chore").firstMatch.label, name)

        app.buttons["In scadenza"].tap()
        let upcoming = app.buttons.matching(NSPredicate(format: "identifier == 'chore' AND (label CONTAINS 'Tra ' OR label CONTAINS 'Domani')")).firstMatch
        XCTAssertTrue(upcoming.waitForExistence(timeout: 5))
        XCTAssertFalse(app.buttons.matching(NSPredicate(format: "identifier == 'chore' AND label CONTAINS 'ritardo'")).firstMatch.exists)
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
        toggle.switches.firstMatch.tap()
        XCTAssertTrue(app.datePickers.firstMatch.waitForExistence(timeout: 5))
        try audit(app)
    }
}
