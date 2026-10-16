import Foundation
import Testing
@testable import SbuLibretto

struct ExamCountdownTests {
    nonisolated static let calendar: Calendar = {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "Europe/Rome") ?? .gmt
        return calendar
    }()

    /// 16 October 2026, 15:00 in Rome.
    nonisolated static let now: Date = calendar.date(from: DateComponents(year: 2026, month: 10, day: 16, hour: 15)) ?? .now

    nonisolated static func at(day: Int, hour: Int = 9, month: Int = 10, year: Int = 2026) -> Date {
        calendar.date(from: DateComponents(year: year, month: month, day: day, hour: hour)) ?? now
    }

    @Test(arguments: [
        (at(day: 16, hour: 0), CountdownDay.today),
        (at(day: 16, hour: 23), .today),
        (at(day: 17, hour: 0), .tomorrow),
        (at(day: 17, hour: 23), .tomorrow),
        (at(day: 18), .inDays(2)),
        (at(day: 15, hour: 23), .yesterday),
        (at(day: 13), .daysAgo(3)),
        (at(day: 1, month: 1, year: 2027), .inDays(77)),
        (at(day: 16, month: 10, year: 2025), .daysAgo(365)),
    ])
    func countsCalendarDaysNotHours(_ date: Date, _ expected: CountdownDay) {
        #expect(CountdownDay(date, from: Self.now, calendar: Self.calendar) == expected)
    }

    @Test func daylightSavingDoesNotLoseADay() {
        // Clocks go back on 25 October 2026 in Rome: that day has 25 hours.
        #expect(CountdownDay(Self.at(day: 26, hour: 0), from: Self.at(day: 24, hour: 23), calendar: Self.calendar) == .inDays(2))
    }

    @Test func pastAndFutureAreTold() {
        #expect(!CountdownDay.today.isPast)
        #expect(!CountdownDay.inDays(4).isPast)
        #expect(CountdownDay.yesterday.isPast)
        #expect(CountdownDay.daysAgo(10).isPast)
    }

    @Test func sittingsAreSplitAndOrdered() throws {
        let items = [
            PlanQueryTests.item("Reti", .pending, day: nil),
            PlanItem(id: UUID(), name: "Fisica II", credits: 6, courseYear: 2, result: .pending, date: Self.at(day: 30)),
            PlanItem(id: UUID(), name: "Basi di dati", credits: 9, courseYear: 2, result: .pending, date: Self.at(day: 16, hour: 8)),
            PlanItem(id: UUID(), name: "Analisi II", credits: 6, courseYear: 2, result: .pending, date: Self.at(day: 2)),
            PlanItem(id: UUID(), name: "Chimica", credits: 6, courseYear: 1, result: .pending, date: Self.at(day: 10)),
            PlanItem(id: UUID(), name: "Algebra", credits: 6, courseYear: 1, result: .graded(.mark(28)), date: Self.at(day: 20)),
            PlanItem(id: UUID(), name: "Inglese", credits: 3, courseYear: 1, result: .passed, date: Self.at(day: 25)),
            PlanQueryTests.item("Algoritmi", .pending, day: nil),
        ]
        let countdown = ExamCountdown(items, now: Self.now, calendar: Self.calendar)
        // An exam this morning is still today's sitting, even if the hour has passed.
        #expect(countdown.upcoming.map(\.name) == ["Basi di dati", "Fisica II"])
        #expect(countdown.overdue.map(\.name) == ["Chimica", "Analisi II"])
        #expect(countdown.undated.map(\.name) == ["Algoritmi", "Reti"])
        let next = try #require(countdown.next)
        #expect(next.day == .today)
        #expect(!countdown.isEmpty)
    }

    @Test func takenExamsNeverCountDown() {
        let items = [PlanItem(id: UUID(), name: "Algebra", credits: 6, courseYear: 1, result: .graded(.mark(28)), date: Self.at(day: 20))]
        let countdown = ExamCountdown(items, now: Self.now, calendar: Self.calendar)
        #expect(countdown.isEmpty)
        #expect(countdown.next == nil)
    }
}
