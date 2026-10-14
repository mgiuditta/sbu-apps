import Foundation
import Testing
@testable import SbuSubscriptions

struct HomeLogicTests {
    let calendar: Calendar = {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "Europe/Rome")!
        return calendar
    }()

    func day(_ year: Int, _ month: Int, _ day: Int) -> Date {
        calendar.date(from: DateComponents(year: year, month: month, day: day))!
    }

    @Test(arguments: [
        ((2026, 10, 14), DueDay.today),
        ((2026, 10, 15), .tomorrow),
        ((2026, 10, 20), .inDays(6)),
    ])
    func dueDay(payment: (Int, Int, Int), expected: DueDay) {
        let now = day(2026, 10, 14).addingTimeInterval(20 * 3600)
        #expect(DueDay(day(payment.0, payment.1, payment.2), from: now, in: calendar) == expected)
    }

    @Test func dueDayAfterAWeekIsADate() {
        let payment = day(2026, 10, 21)
        #expect(DueDay(payment, from: day(2026, 10, 14), in: calendar) == .on(payment))
    }

    @Test(arguments: [("Netflix", "n.circle"), ("  élite", "e.circle"), ("Žena", "z.circle"), ("4K TV", "creditcard"), ("", "creditcard"), ("音乐", "creditcard")])
    func monogram(name: String, expected: String) {
        #expect(Monogram.systemImage(for: name) == expected)
    }

    @Test func groupsSplitAndSortTheHome() {
        func make(_ name: String, start: Date) -> Subscription {
            Subscription(name: name, price: 5, currencyCode: "EUR", startDate: start)
        }
        let later = make("Later", start: day(2026, 1, 30))
        let sooner = make("Sooner", start: day(2026, 1, 16))
        let trial = make("Trial", start: day(2026, 10, 20))
        trial.trialEndDate = day(2026, 10, 20)
        let paused = make("Paused", start: day(2026, 1, 1))
        paused.status = .paused
        let cancelled = make("Cancelled", start: day(2026, 1, 1))
        cancelled.status = .cancelled
        let finished = make("Finished", start: day(2026, 1, 1))
        finished.paymentCount = 2

        let groups = SubscriptionGroups([later, trial, paused, sooner, cancelled, finished], on: day(2026, 10, 14), in: calendar)
        #expect(groups.active.map(\.name) == ["Sooner", "Later"])
        #expect(groups.trials.map(\.name) == ["Trial"])
        #expect(groups.paused.map(\.name) == ["Paused"])
        #expect(groups.cancelled.map(\.name) == ["Cancelled"])
        #expect(groups.finished.map(\.name) == ["Finished"])
        #expect(Set(groups.counted.map(\.name)) == ["Sooner", "Later"])
    }
}
