import Foundation
import Testing
@testable import SbuHabits

struct SleepTotalTests {
    private let calendar: Calendar = {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "Europe/Rome")!
        return calendar
    }()

    private func date(_ day: Int, _ hour: Int, _ minute: Int = 0) -> Date {
        calendar.date(from: DateComponents(year: 2026, month: 10, day: day, hour: hour, minute: minute))!
    }

    /// The logical day of 13 October with the day starting at `startHour`.
    private func day(startHour: Int = 4) -> DateInterval {
        DateInterval(start: date(13, startHour), end: date(14, startHour))
    }

    @Test(arguments: [0, 4])
    func theNightCountsForTheDayYouWakeUpIn(startHour: Int) {
        let night = [
            DateInterval(start: date(12, 23), end: date(13, 2)),
            DateInterval(start: date(13, 2), end: date(13, 7)),
        ]

        #expect(SleepTotal.total(of: night, wakingWithin: day(startHour: startHour)) == 8 * 60)
    }

    @Test func aNightAcrossTheStartOfTheDayCountsWhole() {
        // The day starts at 4: the part before 4 is still this night's.
        let night = [
            DateInterval(start: date(13, 1), end: date(13, 3, 30)),
            DateInterval(start: date(13, 3, 30), end: date(13, 8)),
        ]

        #expect(SleepTotal.total(of: night, wakingWithin: day()) == 7 * 60)
    }

    @Test func aNightEndingTomorrowIsNotToday() {
        let tonight = [DateInterval(start: date(13, 23), end: date(14, 7))]

        #expect(SleepTotal.total(of: tonight, wakingWithin: day()) == 0)
    }

    @Test func aNightEndingBeforeTheDayIsYesterdays() {
        // With the day starting at 4, a short night that ends at 3 belongs to the 12th.
        let early = [DateInterval(start: date(12, 22), end: date(13, 3))]

        #expect(SleepTotal.total(of: early, wakingWithin: day()) == 0)
    }

    @Test func awakeTimeInTheNightIsNotSleep() {
        let night = [
            DateInterval(start: date(12, 23), end: date(13, 3)),
            DateInterval(start: date(13, 4), end: date(13, 7)),
        ]

        #expect(SleepTotal.total(of: night, wakingWithin: day()) == 7 * 60)
    }

    @Test func aNapCountsForItsDay() {
        let sleeps = [
            DateInterval(start: date(12, 23), end: date(13, 7)),
            DateInterval(start: date(13, 14), end: date(13, 14, 30)),
        ]

        #expect(SleepTotal.total(of: sleeps, wakingWithin: day()) == 8 * 60 + 30)
    }

    @Test func periodsLoggedTwiceCountOnce() {
        // iPhone and Watch both logged the night.
        let night = [
            DateInterval(start: date(12, 23), end: date(13, 7)),
            DateInterval(start: date(12, 23, 30), end: date(13, 6)),
            DateInterval(start: date(12, 23), end: date(13, 7)),
        ]

        #expect(SleepTotal.total(of: night, wakingWithin: day()) == 8 * 60)
    }

    @Test func periodsInAnyOrderAddUp() {
        let night = [
            DateInterval(start: date(13, 5), end: date(13, 7)),
            DateInterval(start: date(12, 23), end: date(13, 5)),
        ]

        #expect(SleepTotal.total(of: night, wakingWithin: day()) == 8 * 60)
    }

    @Test func noSleepIsZero() {
        #expect(SleepTotal.total(of: [], wakingWithin: day()) == 0)
    }
}
