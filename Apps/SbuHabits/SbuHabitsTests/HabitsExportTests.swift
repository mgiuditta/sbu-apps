import Foundation
import Testing
@testable import SbuHabits

struct HabitsExportTests {
    /// A file with every kind of data a habit keeps: log, mark hours, skips, reminders, an edit, a
    /// Limite, a countdown, a monthly schedule, an Attività di un giorno, Orari automatici and
    /// every notification setting.
    static let sample: HabitsFile = {
        let start = LogicalDay(ordinal: 20_000)
        var water = Habit(title: "Bere acqua", symbol: "drop", timesPerDay: 8, createdOn: start)
        water.log = [start: 8, start + 1: 3]
        water.skipped = [start + 2]
        _ = water.update(title: "Bere acqua", symbol: "drop", timesPerDay: 6, schedule: .weekdays([2, 4, 6]), from: start + 3)
        water.reminders = [ReminderTime(hour: 9, minute: 30)]
        water.mark(on: start + 4, hour: 7)
        water.mark(on: start + 4, hour: 13)
        var coffee = Habit(title: "Caffè", symbol: "cup.and.saucer", limit: 2, createdOn: start + 1)
        coffee.log = [start + 1: 3]
        coffee.mark(on: start + 2, hour: 23)
        var gym = Habit(title: "Palestra", symbol: "dumbbell", schedule: .timesPerWeek(3), createdOn: start)
        _ = gym.update(title: "Palestra", symbol: "dumbbell", timesPerDay: 1, schedule: .timesPerWeek(3), remindsAutomatically: true, notificationStyle: NotificationStyle(isTimeSensitive: true, sound: .carta), from: start)
        var walk = Habit(title: "Camminare", symbol: "figure.walk", createdOn: start)
        _ = walk.update(title: "Camminare", symbol: "figure.walk", timesPerDay: 1, schedule: .everyDay, notificationStyle: NotificationStyle(sound: .silent, announcesHealthMark: true), health: HealthLink(measure: .steps, goal: 8_000), from: start)
        var reading = Habit(title: "Leggere", symbol: "book", createdOn: start)
        _ = reading.update(title: "Leggere", symbol: "book", timesPerDay: 1, schedule: .everyDay, timerMinutes: 20, from: start)
        reading.mark(on: start + 1, hour: 22)
        reading.setNote("Venti pagine\nPoi a letto", on: start + 1)
        reading.setNote("Saltata, influenza", on: start + 2)
        var books = Habit(title: "Biblioteca", symbol: "books.vertical", schedule: .timesPerMonth(2), createdOn: start)
        books.log = [start + 5: 1]
        var dentist = Habit(title: "Dentista", symbol: "pills", schedule: .oneDay(start + 9), createdOn: start)
        dentist.reminders = [ReminderTime(hour: 8, minute: 0)]
        return HabitsFile(habits: [water, coffee, gym, reading, books, dentist, walk], startHour: 4)
    }()

    @Test func anExportReadsBackAsTheSameData() throws {
        let export = HabitsExport(file: Self.sample, date: .now)

        let read = try JSONDecoder().decode(HabitsFile.self, from: try export.data())

        #expect(read == Self.sample)
        #expect(read.habits[0].markHours == [LogicalDay(ordinal: 20_004): [7, 13]])
        #expect(read.habits[3].timerMinutes == 20)
        #expect(read.habits[3].note(on: LogicalDay(ordinal: 20_001)) == "Venti pagine\nPoi a letto")
        #expect(read.habits[4].schedule == .timesPerMonth(2))
        #expect(read.habits[5].schedule == .oneDay(LogicalDay(ordinal: 20_009)))
        #expect(read.habits[2].reminderMode == .automatic)
        #expect(read.habits[2].notificationStyle == NotificationStyle(isTimeSensitive: true, sound: .carta))
        #expect(read.habits[5].reminderMode == .custom)
        #expect(read.habits[6].notificationStyle == NotificationStyle(sound: .silent, announcesHealthMark: true))
    }

    @Test func theFileSaysItsFormatVersion() throws {
        let data = try HabitsExport(file: Self.sample, date: .now).data()

        let json = try #require(try JSONSerialization.jsonObject(with: data) as? [String: Any])

        #expect(json["version"] as? Int == HabitsFile.currentVersion)
    }

    @Test func theFileNameCarriesTheDay() throws {
        let noon = try #require(Calendar.current.date(from: DateComponents(year: 2026, month: 10, day: 12, hour: 12)))

        #expect(HabitsExport(file: HabitsFile(), date: noon).fileName == "Sbu Habits 2026-10-12.json")
    }
}
