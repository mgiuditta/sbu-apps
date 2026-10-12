import Foundation
import Testing
@testable import SbuHabits

struct LogicalDayTests {
    private let calendar: Calendar = {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "Europe/Rome")!
        return calendar
    }()

    private func date(_ year: Int, _ month: Int, _ day: Int, _ hour: Int, _ minute: Int = 0) -> Date {
        calendar.date(from: DateComponents(year: year, month: month, day: day, hour: hour, minute: minute))!
    }

    @Test func midnightStartsANewDay() {
        let evening = LogicalDay(date(2026, 10, 12, 23, 59), calendar: calendar)
        let morning = LogicalDay(date(2026, 10, 13, 0, 0), calendar: calendar)

        #expect(morning.ordinal == evening.ordinal + 1)
    }

    @Test(arguments: [(1, true), (3, true), (4, false), (12, false)])
    func withADayStartingAtFourEarlyHoursBelongToTheDayBefore(hour: Int, isDayBefore: Bool) {
        let day = LogicalDay(date(2026, 10, 13, hour), startHour: 4, calendar: calendar)
        let thirteenth = LogicalDay(date(2026, 10, 13, 12), calendar: calendar)

        #expect((day == thirteenth - 1) == isDayBefore)
    }

    @Test(arguments: [
        (2026, 3, 29), // clocks go forward in Rome
        (2026, 10, 25), // clocks go back in Rome
        (2026, 12, 31), // end of year
    ])
    func consecutiveDaysAreOneApartAcrossTheCalendar(year: Int, month: Int, day: Int) {
        let today = LogicalDay(date(year, month, day, 12), calendar: calendar)
        let tomorrow = LogicalDay(calendar.date(byAdding: .day, value: 1, to: date(year, month, day, 12))!, calendar: calendar)

        #expect(tomorrow.ordinal == today.ordinal + 1)
    }

    @Test func survivesAJSONRoundTripAsADictionaryKey() throws {
        let log = [LogicalDay(ordinal: 20_373): 2]

        let data = try JSONEncoder().encode(log)

        #expect(String(decoding: data, as: UTF8.self) == #"{"20373":2}"#)
        #expect(try JSONDecoder().decode([LogicalDay: Int].self, from: data) == log)
    }
}
