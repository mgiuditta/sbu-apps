import Foundation
import Testing
@testable import SbuChats

struct ActivityChartDataTests {
    private static let calendar: Calendar = {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "Europe/Rome") ?? .gmt
        return calendar
    }()

    @Test func everyHourHasASlotEvenWithoutMessages() {
        let data = ActivityChartData(axis: .hour, points: [ActivityPoint(slot: 21, series: .you, count: 4)],
                                     calendar: Self.calendar, locale: Locale(identifier: "it_IT"))
        #expect(data.slots.count == 24)
        #expect(data.slots[21].label == "21")
        #expect(data.bars.count == 24)
        #expect(data.peak?.id == 21)
    }

    @Test func hoursFollowTheLocaleClock() {
        let data = ActivityChartData(axis: .hour, points: [], calendar: Self.calendar, locale: Locale(identifier: "en_US"))
        #expect(data.slots[21].label.contains("9"))
        #expect(data.slots[21].label.uppercased().contains("PM"))
    }

    @Test(arguments: [("it_IT", 2), ("en_US", 1)])
    func weekdaysStartOnTheLocalesFirstDay(identifier: String, firstWeekday: Int) {
        var calendar = Self.calendar
        calendar.locale = Locale(identifier: identifier)
        calendar.firstWeekday = firstWeekday
        let data = ActivityChartData(axis: .weekday, points: [], calendar: calendar, locale: Locale(identifier: identifier))
        #expect(data.slots.first?.id == firstWeekday)
        #expect(data.slots.count == 7)
    }

    @Test func monthsFillTheGapsBetweenFirstAndLast() {
        let points = [ActivityPoint(slot: 2024 * 12 + 10, series: .others, count: 3), ActivityPoint(slot: 2025 * 12 + 1, series: .you, count: 5)]
        let data = ActivityChartData(axis: .month, points: points, calendar: Self.calendar, locale: Locale(identifier: "it_IT"))
        #expect(data.slots.count == 4) // nov, dic, gen, feb
        #expect(data.bars.count == 8) // two series in every slot
        #expect(data.total(in: data.slots[3]) == 5)
        #expect(data.count(in: data.slots[0], series: .others) == 3)
        #expect(data.peak == data.slots[3])
    }

    @Test func anEmptyChartHasNoPeak() {
        #expect(ActivityChartData(axis: .year, points: []).peak == nil)
    }
}
