import Foundation
import Testing
@testable import SbuSubscriptions

struct RenewalStatusTests {
    let calendar: Calendar = {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "Europe/Rome")!
        return calendar
    }()

    func day(_ year: Int, _ month: Int, _ day: Int) -> Date {
        calendar.date(from: DateComponents(year: year, month: month, day: day))!
    }

    @Test(arguments: [(16, 0), (17, 1), (20, 4)])
    func renewsInWholeDays(paymentDay: Int, days: Int) {
        let today = day(2026, 10, 16).addingTimeInterval(22 * 3600)
        let next = day(2026, 10, paymentDay)
        let status = RenewalStatus(status: .active, trialEnd: nil, nextPayment: next, today: today, calendar: calendar)
        #expect(status == .renews(inDays: days, on: next))
    }

    @Test func renewsAMonthAwayStillCountsTheDays() {
        let next = day(2026, 11, 16)
        let status = RenewalStatus(status: .active, trialEnd: nil, nextPayment: next, today: day(2026, 10, 16), calendar: calendar)
        #expect(status == .renews(inDays: 31, on: next))
    }

    @Test func aTrialSaysWhenItEnds() {
        let end = day(2026, 10, 21)
        let status = RenewalStatus(status: .active, trialEnd: end, nextPayment: end, today: day(2026, 10, 16), calendar: calendar)
        #expect(status == .trialEnds(inDays: 5, on: end))
    }

    @Test(arguments: [
        (SubscriptionStatus.paused, RenewalStatus.paused),
        (.cancelled, .cancelled),
    ])
    func stoppedOnesSayWhy(state: SubscriptionStatus, expected: RenewalStatus) {
        #expect(RenewalStatus(status: state, trialEnd: nil, nextPayment: nil, today: day(2026, 10, 16), calendar: calendar) == expected)
    }

    @Test(arguments: [(0, true), (6, true), (7, false), (31, false)])
    func theMarkIsFilledWithinTheWeek(days: Int, filled: Bool) {
        let on = day(2026, 10, 16)
        #expect(RenewalStatus.renews(inDays: days, on: on).isWithinWeek == filled)
        #expect(RenewalStatus.trialEnds(inDays: days, on: on).isWithinWeek == filled)
    }

    @Test(arguments: [RenewalStatus.paused, .cancelled, .finished])
    func stoppedOnesHaveNoDayAndAnEmptyMark(status: RenewalStatus) {
        #expect(status.day == nil)
        #expect(!status.isWithinWeek)
    }

    @Test func theDayIsTheRenewal() {
        let on = day(2026, 10, 20)
        #expect(RenewalStatus.renews(inDays: 4, on: on).day == on)
    }

    @Test func withoutANextPaymentItIsFinished() {
        #expect(RenewalStatus(status: .active, trialEnd: nil, nextPayment: nil, today: day(2026, 10, 16), calendar: calendar) == .finished)
    }
}
