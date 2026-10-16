import Foundation
import Testing
@testable import SbuSubscriptions

struct SubscriptionTallyTests {
    let calendar: Calendar = {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "Europe/Rome")!
        return calendar
    }()

    func day(_ year: Int, _ month: Int, _ day: Int) -> Date {
        calendar.date(from: DateComponents(year: year, month: month, day: day))!
    }

    func tally(start: Date, cycle: BillingCycle = .monthly, count: Int? = nil, addedOn: Date? = nil, stoppedOn: Date? = nil,
               today: Date, price: @escaping (Date) -> Decimal = { _ in 10 }) -> SubscriptionTally {
        SubscriptionTally(schedule: BillingSchedule(start: start, cycle: cycle, paymentCount: count), addedOn: addedOn ?? today,
                          stoppedOn: stoppedOn, today: today, calendar: calendar, price: price)
    }

    @Test func countsEveryPaymentUpToTodayIncluded() {
        let result = tally(start: day(2026, 1, 16), today: day(2026, 10, 16).addingTimeInterval(9 * 3600))
        #expect(result.paymentCount == 10)
        #expect(result.spent == 100)
    }

    @Test func aFirstPaymentStillToComeHasCostNothing() {
        let result = tally(start: day(2026, 10, 20), today: day(2026, 10, 16))
        #expect(result.paymentCount == 0)
        #expect(result.spent == 0)
    }

    @Test func eachPaymentAtItsPriceThatDay() {
        let rise = day(2026, 3, 1)
        let result = tally(start: day(2026, 1, 1), today: day(2026, 4, 15)) { $0 < rise ? 10 : 12 }
        #expect(result.spent == Decimal(44), "10 + 10 + 12 + 12")
    }

    @Test func noPaymentCountsAfterItStopped() {
        let result = tally(start: day(2026, 1, 1), stoppedOn: day(2026, 3, 15), today: day(2026, 10, 16))
        #expect(result.paymentCount == 3)
    }

    @Test func anInstalmentPlanStopsAtItsLastPayment() {
        let result = tally(start: day(2025, 1, 1), count: 6, today: day(2026, 10, 16))
        #expect(result.paymentCount == 6)
    }

    @Test func sinceIsTheFirstPaymentOrTheDayAddedIfEarlier() {
        #expect(tally(start: day(2025, 10, 16), addedOn: day(2026, 10, 1), today: day(2026, 10, 16)).since == day(2025, 10, 16))
        #expect(tally(start: day(2026, 11, 1), addedOn: day(2026, 10, 1), today: day(2026, 10, 16)).since == day(2026, 10, 1))
    }

    @Test func tenureShowsTheLargestUnits() {
        let today = day(2026, 10, 16)
        func fields(from start: Date) -> Set<Date.ComponentsFormatStyle.Field> {
            tally(start: start, addedOn: today, today: today).tenureFields(on: today, calendar: calendar)
        }
        #expect(fields(from: day(2025, 10, 16)) == [.year])
        #expect(fields(from: day(2025, 8, 1)) == [.year, .month])
        #expect(fields(from: day(2026, 7, 10)) == [.month])
        #expect(fields(from: day(2026, 10, 2)) == [.day])
    }
}
