import Foundation
import Testing
@testable import SbuHabits

struct HabitsExportTests {
    /// A file with every kind of data a habit keeps: log, skips, reminders, an edit, a Limite.
    static let sample: HabitsFile = {
        let start = LogicalDay(ordinal: 20_000)
        var water = Habit(title: "Bere acqua", symbol: "drop", timesPerDay: 8, createdOn: start)
        water.log = [start: 8, start + 1: 3]
        water.skipped = [start + 2]
        _ = water.update(title: "Bere acqua", symbol: "drop", timesPerDay: 6, schedule: .weekdays([2, 4, 6]), from: start + 3)
        water.reminders = [ReminderTime(hour: 9, minute: 30)]
        var coffee = Habit(title: "Caffè", symbol: "cup.and.saucer", limit: 2, createdOn: start + 1)
        coffee.log = [start + 1: 3]
        let gym = Habit(title: "Palestra", symbol: "dumbbell", schedule: .timesPerWeek(3), createdOn: start)
        return HabitsFile(habits: [water, coffee, gym], startHour: 4)
    }()

    @Test func anExportReadsBackAsTheSameData() throws {
        let export = HabitsExport(file: Self.sample, date: .now)

        let read = try JSONDecoder().decode(HabitsFile.self, from: try export.data())

        #expect(read == Self.sample)
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
