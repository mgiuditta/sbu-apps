import Foundation
import Testing
@testable import SbuChats

struct DateRangeOptionTests {
    private static let calendar: Calendar = {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "Europe/Rome") ?? .gmt
        return calendar
    }()

    private func date(_ year: Int, _ month: Int, _ day: Int, _ hour: Int = 0, _ minute: Int = 0, _ second: Int = 0) -> Date {
        Self.calendar.date(from: DateComponents(year: year, month: month, day: day, hour: hour, minute: minute, second: second)) ?? .distantPast
    }

    private func bounds(_ option: DateRangeOption, start: Date? = nil, end: Date? = nil) -> (start: Date?, end: Date?) {
        option.bounds(lastMessage: date(2024, 3, 15, 18, 30), customStart: start ?? date(2024, 1, 1), customEnd: end ?? date(2024, 1, 1), calendar: Self.calendar)
    }

    @Test func allHasNoLimits() {
        let range = bounds(.all)
        #expect(range.start == nil)
        #expect(range.end == nil)
    }

    @Test(arguments: [
        (DateRangeOption.last30Days, 2024, 2, 15),
        (.last6Months, 2023, 9, 16),
        (.lastYear, 2023, 3, 16),
    ])
    func recentPeriodsEndOnTheLastMessagesDay(option: DateRangeOption, year: Int, month: Int, day: Int) {
        let range = bounds(option)
        #expect(range.start == date(year, month, day))
        #expect(range.end == date(2024, 3, 15, 23, 59, 59))
    }

    @Test func aCustomPeriodIncludesBothDaysWhole() {
        let range = bounds(.custom, start: date(2024, 2, 10, 15), end: date(2024, 2, 1, 9))
        #expect(range.start == date(2024, 2, 1))
        #expect(range.end == date(2024, 2, 10, 23, 59, 59))
    }
}
