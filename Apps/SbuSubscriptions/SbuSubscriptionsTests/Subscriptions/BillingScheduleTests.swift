import Foundation
import Testing
@testable import SbuSubscriptions

struct BillingScheduleTests {
    let calendar: Calendar = {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "Europe/Rome")!
        return calendar
    }()

    func day(_ year: Int, _ month: Int, _ day: Int) -> Date {
        calendar.date(from: DateComponents(year: year, month: month, day: day))!
    }

    @Test(arguments: [
        // Month end: counted from the start, so March is back to the 31st.
        (BillingCycle.monthly, (2026, 1, 31), (2026, 2, 1), (2026, 2, 28)),
        (BillingCycle.monthly, (2026, 1, 31), (2026, 3, 1), (2026, 3, 31)),
        (BillingCycle.monthly, (2028, 1, 31), (2028, 2, 1), (2028, 2, 29)),
        // Leap day: 28 February in between, 29 again in the next leap year.
        (BillingCycle.yearly, (2024, 2, 29), (2025, 1, 1), (2025, 2, 28)),
        (BillingCycle.yearly, (2024, 2, 29), (2027, 3, 1), (2028, 2, 29)),
        // A payment today is still the next one.
        (BillingCycle.monthly, (2026, 1, 15), (2026, 10, 15), (2026, 10, 15)),
        (BillingCycle.weekly, (2026, 10, 1), (2026, 10, 9), (2026, 10, 15)),
        (BillingCycle.every(3, .month), (2026, 1, 10), (2026, 4, 11), (2026, 7, 10)),
        (BillingCycle.every(2, .day), (2020, 1, 1), (2026, 10, 14), (2026, 10, 14)),
        // Before the start, the next payment is the first one.
        (BillingCycle.monthly, (2026, 12, 1), (2026, 10, 14), (2026, 12, 1)),
    ])
    func nextPayment(cycle: BillingCycle, start: (Int, Int, Int), from: (Int, Int, Int), expected: (Int, Int, Int)) {
        let schedule = BillingSchedule(start: day(start.0, start.1, start.2), cycle: cycle)
        let next = schedule.nextPayment(onOrAfter: day(from.0, from.1, from.2), in: calendar)
        #expect(next == day(expected.0, expected.1, expected.2))
    }

    @Test func oneOffPaymentEndsAfterItsDay() {
        let schedule = BillingSchedule(start: day(2026, 10, 1), cycle: .once)
        #expect(schedule.nextPayment(onOrAfter: day(2026, 10, 1), in: calendar) == day(2026, 10, 1))
        #expect(schedule.nextPayment(onOrAfter: day(2026, 10, 2), in: calendar) == nil)
    }

    @Test func instalmentsStopAfterTheLastPayment() {
        let schedule = BillingSchedule(start: day(2026, 1, 5), cycle: .monthly, paymentCount: 3)
        #expect(schedule.nextPayment(onOrAfter: day(2026, 3, 1), in: calendar) == day(2026, 3, 5))
        #expect(schedule.nextPayment(onOrAfter: day(2026, 3, 6), in: calendar) == nil)
    }

    @Test func timeOfDayIsIgnored() {
        let start = day(2026, 1, 15).addingTimeInterval(23 * 3600)
        let schedule = BillingSchedule(start: start, cycle: .monthly)
        let lateOnPaymentDay = day(2026, 2, 15).addingTimeInterval(22 * 3600)
        #expect(schedule.nextPayment(onOrAfter: lateOnPaymentDay, in: calendar) == day(2026, 2, 15))
    }

    @Test func paymentsInARangeIncludeStartAndExcludeEnd() {
        let schedule = BillingSchedule(start: day(2026, 1, 1), cycle: .weekly)
        let payments = schedule.payments(from: day(2026, 10, 1), to: day(2026, 11, 1), in: calendar)
        #expect(payments == [day(2026, 10, 1), day(2026, 10, 8), day(2026, 10, 15), day(2026, 10, 22), day(2026, 10, 29)])
        #expect(schedule.payments(from: day(2026, 10, 1), to: day(2026, 10, 8), in: calendar) == [day(2026, 10, 1)])
    }

    @Test func paymentsAcrossDaylightSavingKeepTheDay() {
        // Clocks go back in Rome on 25 October 2026.
        let schedule = BillingSchedule(start: day(2026, 10, 20), cycle: .every(1, .day))
        let payments = schedule.payments(from: day(2026, 10, 24), to: day(2026, 10, 27), in: calendar)
        #expect(payments == [day(2026, 10, 24), day(2026, 10, 25), day(2026, 10, 26)])
    }

    @Test(arguments: [0, -1])
    func zeroOrNegativeIntervalPaysOnce(interval: Int) {
        let schedule = BillingSchedule(start: day(2026, 1, 1), cycle: .every(interval, .month))
        #expect(schedule.payments(from: day(2025, 1, 1), to: day(2027, 1, 1), in: calendar) == [day(2026, 1, 1)])
    }
}
