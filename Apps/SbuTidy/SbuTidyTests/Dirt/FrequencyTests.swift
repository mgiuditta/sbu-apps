import Foundation
import Testing
@testable import SbuTidy

struct FrequencyTests {
    @Test(arguments: [
        (0, FrequencyUnit.day, 1), (-5, .day, 1), (Int.min, .day, 1), (Int.max, .day, 365), (366, .day, 365), (365, .day, 365),
        (0, .week, 1), (53, .week, 52), (52, .week, 52), (Int.max, .week, 52),
        (0, .month, 1), (25, .month, 24), (24, .month, 24), (-1, .month, 1), (3, .month, 3),
    ])
    func valueIsClampedToTheUnitRange(value: Int, unit: FrequencyUnit, expected: Int) {
        #expect(Frequency(value, unit).value == expected)
    }

    @Test(arguments: [
        (Frequency(1, .day), Fixtures.date(2026, 10, 15)),
        (Frequency(3, .day), Fixtures.date(2026, 10, 17)),
        (Frequency(1, .week), Fixtures.date(2026, 10, 21)),
        (Frequency(2, .week), Fixtures.date(2026, 10, 28)),
        (Frequency(1, .month), Fixtures.date(2026, 11, 14)),
        (Frequency(12, .month), Fixtures.date(2027, 10, 14)),
    ])
    func dueDateAddsTheFrequencyInCalendarUnits(frequency: Frequency, expected: Date) {
        #expect(frequency.dueDate(after: Fixtures.now, calendar: Fixtures.calendar) == expected)
    }

    @Test func aMonthFromTheThirtyFirstEndsOnTheLastDayOfAShorterMonth() {
        let due = Frequency(1, .month).dueDate(after: Fixtures.date(2027, 1, 31), calendar: Fixtures.calendar)
        #expect(due == Fixtures.date(2027, 2, 28))
    }

    @Test func aDayAcrossTheEndOfDaylightSavingIsStillTheSameClockTime() {
        // Rome leaves summer time on 25 October 2026: that day lasts 25 hours.
        let due = Frequency(1, .day).dueDate(after: Fixtures.date(2026, 10, 24, 10), calendar: Fixtures.calendar)
        #expect(due == Fixtures.date(2026, 10, 25, 10))
    }

    @Test(arguments: FrequencyUnit.allCases)
    func lengthIsAlwaysPositive(unit: FrequencyUnit) {
        for value in [Int.min, 0, 1, Int.max] {
            #expect(Frequency(value, unit).length(from: Fixtures.now, calendar: Fixtures.calendar) > 0)
        }
    }

    @Test(arguments: FrequencyUnit.allCases)
    func rangeStartsAtOne(unit: FrequencyUnit) {
        #expect(unit.range.lowerBound == 1)
    }
}
