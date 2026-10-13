import Foundation
import Testing
@testable import SbuHabits

/// Nota del giorno: one per habit per logical day, trimmed, never blank, never too long.
struct DailyNoteTests {
    private let today = LogicalDay(ordinal: 20_010)
    private let store = HabitsStore(url: .temporaryDirectory.appending(path: "DailyNoteTests-\(UUID().uuidString).json"))

    private var rome: Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "Europe/Rome")!
        return calendar
    }

    private func habit() -> Habit {
        Habit(title: "Leggere", symbol: "book", createdOn: today - 30)
    }

    @Test(arguments: [
        ("Letto venti pagine", "Letto venti pagine"),
        ("  Letto venti pagine \n", "Letto venti pagine"),
        ("Prima riga\n\nSeconda riga", "Prima riga\n\nSeconda riga"), // new lines inside stay
        ("Caffè ☕️ e libro", "Caffè ☕️ e libro"),
    ])
    func aNoteIsSavedTrimmed(text: String, saved: String) {
        #expect(DailyNote.normalized(text) == saved)
    }

    @Test(arguments: ["", " ", "\n\n", " \t \n "])
    func aBlankNoteIsNoNote(text: String) {
        #expect(DailyNote.normalized(text) == nil)
    }

    @Test(arguments: [
        (DailyNote.maxLength - 1, DailyNote.maxLength - 1),
        (DailyNote.maxLength, DailyNote.maxLength),
        (DailyNote.maxLength + 1, DailyNote.maxLength),
        (DailyNote.maxLength * 3, DailyNote.maxLength),
    ])
    func aNoteIsCutToTheMaximumLength(length: Int, saved: Int) {
        let text = String(repeating: "a", count: length)

        #expect(DailyNote.normalized(text)?.count == saved)
        #expect(DailyNote.limited(text).count == saved)
    }

    @Test func charactersCountAsTheyLookNotAsBytes() {
        // Each emoji is one character, many bytes: the limit counts what the counter shows.
        let text = String(repeating: "👩🏽‍💻", count: DailyNote.maxLength + 5)

        #expect(DailyNote.normalized(text)?.count == DailyNote.maxLength)
    }

    @Test func whileTypingSpacesAndNewLinesStay() {
        #expect(DailyNote.limited("Oggi \n") == "Oggi \n")
    }

    @Test func aCutNoteEndsWithoutSpaces() {
        let text = String(repeating: "a", count: DailyNote.maxLength - 1) + "   bbb"

        #expect(DailyNote.normalized(text) == String(repeating: "a", count: DailyNote.maxLength - 1))
    }

    @Test func eachDayHasItsOwnNote() {
        var reading = habit()

        reading.setNote("Ieri", on: today - 1)
        reading.setNote("Oggi", on: today)

        #expect(reading.note(on: today - 1) == "Ieri")
        #expect(reading.note(on: today) == "Oggi")
        #expect(reading.note(on: today - 2) == nil)
    }

    @Test(arguments: ["Riscritta", "  Riscritta  "])
    func writingAgainReplacesTheNote(text: String) {
        var reading = habit()
        reading.setNote("Prima", on: today)

        reading.setNote(text, on: today)

        #expect(reading.note(on: today) == "Riscritta")
    }

    @Test(arguments: ["", "   \n"])
    func clearingTheTextRemovesTheNote(text: String) {
        var reading = habit()
        reading.setNote("Prima", on: today)

        reading.setNote(text, on: today)

        #expect(reading.note(on: today) == nil)
        #expect(reading.notes.isEmpty)
    }

    @Test func skippingTheDayKeepsItsNote() {
        var reading = habit()
        reading.mark(on: today, hour: 9)
        reading.setNote("Influenza", on: today)

        reading.toggleSkip(on: today)
        #expect(reading.note(on: today) == "Influenza")

        reading.toggleSkip(on: today)
        #expect(reading.note(on: today) == "Influenza")
    }

    @Test func undoingAMarkKeepsTheNote() {
        var reading = habit()
        reading.mark(on: today, hour: 9)
        reading.setNote("Venti pagine", on: today)

        reading.undoLast(on: today)

        #expect(reading.note(on: today) == "Venti pagine")
    }

    @Test func aNoteWrittenAfterMidnightGoesOnTheLogicalDay() throws {
        // 01:30 on the 13th with a day starting at 4 is still the 12th.
        let night = try #require(rome.date(from: DateComponents(year: 2026, month: 10, day: 13, hour: 1, minute: 30)))
        let noonBefore = try #require(rome.date(from: DateComponents(year: 2026, month: 10, day: 12, hour: 12)))
        let model = HabitsModel(store: store, now: { night }, calendar: rome, scheduleReminders: { _ in })
        model.setStartHour(4)
        model.add(title: "Leggere", symbol: "book")

        model.setNote("Letto fino a tardi", for: model.habits[0], on: model.today)

        #expect(model.habits[0].notes == [LogicalDay(noonBefore, calendar: rome): "Letto fino a tardi"])
    }

    @Test func theModelSavesANoteForAPastDay() {
        let model = HabitsModel(store: store, scheduleReminders: { _ in })
        model.add(title: "Leggere", symbol: "book")

        model.setNote("Recuperata", for: model.habits[0], on: model.today - 3)

        let reloaded = HabitsModel(store: store, scheduleReminders: { _ in })
        #expect(reloaded.habits[0].note(on: model.today - 3) == "Recuperata")
    }

    @Test func aDayStillToComeTakesNoNote() {
        let model = HabitsModel(store: store, scheduleReminders: { _ in })
        model.add(title: "Leggere", symbol: "book")

        model.setNote("Domani", for: model.habits[0], on: model.today + 1)

        #expect(model.habits[0].notes.isEmpty)
    }

    @Test func skippingInTheAppKeepsTheNote() {
        let model = HabitsModel(store: store, scheduleReminders: { _ in })
        model.add(title: "Leggere", symbol: "book")
        model.setNote("Influenza", for: model.habits[0], on: model.today)

        model.toggleSkip(model.habits[0])

        #expect(model.habits[0].note(on: model.today) == "Influenza")
    }

    @Test func deletingAHabitDeletesItsNotes() throws {
        let model = HabitsModel(store: store, scheduleReminders: { _ in })
        model.add(title: "Leggere", symbol: "book")
        model.add(title: "Camminare", symbol: "figure.walk")
        model.setNote("Venti pagine", for: model.habits[0], on: model.today)
        model.setNote("Al parco", for: model.habits[1], on: model.today)

        model.delete(model.habits[0])

        let file = try store.load()
        #expect(file.habits.map(\.notes) == [[model.today: "Al parco"]])
    }
}
