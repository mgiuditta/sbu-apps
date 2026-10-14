import Foundation
import Testing
@testable import SbuSubscriptions

struct CountsInTotalTests {
    let calendar: Calendar = {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "Europe/Rome")!
        return calendar
    }()

    func day(_ year: Int, _ month: Int, _ day: Int) -> Date {
        calendar.date(from: DateComponents(year: year, month: month, day: day))!
    }

    func subscription(_ configure: (Subscription) -> Void = { _ in }) -> Subscription {
        let subscription = Subscription(name: "Video", price: 8, currencyCode: "EUR", startDate: day(2026, 1, 1))
        configure(subscription)
        return subscription
    }

    @Test func activeCounts() {
        #expect(subscription().countsInTotal(on: day(2026, 10, 14), in: calendar))
    }

    @Test func trialDoesNotCountUntilItEnds() {
        let trial = subscription { $0.trialEndDate = day(2026, 10, 20) }
        #expect(!trial.countsInTotal(on: day(2026, 10, 14), in: calendar))
        #expect(trial.countsInTotal(on: day(2026, 10, 20), in: calendar))
    }

    @Test(arguments: [SubscriptionStatus.paused, .cancelled])
    func stoppedDoesNotCount(status: SubscriptionStatus) {
        #expect(!subscription { $0.status = status }.countsInTotal(on: day(2026, 10, 14), in: calendar))
    }

    @Test func paidOffInstalmentsDoNotCount() {
        let plan = subscription { $0.paymentCount = 3 }
        #expect(plan.countsInTotal(on: day(2026, 2, 14), in: calendar))
        #expect(!plan.countsInTotal(on: day(2026, 3, 2), in: calendar))
    }

    @Test func oneOffDoesNotCount() {
        #expect(!subscription { $0.cycle = .once }.countsInTotal(on: day(2025, 12, 1), in: calendar))
    }
}
