import Foundation

/// The next payments across subscriptions, soonest first, at the price each will cost on its day.
nonisolated struct UpcomingPayment: Hashable, Sendable {
    var name: String
    var day: Date
    var price: Decimal
    var currencyCode: String
}

enum UpcomingPayments {
    static func next(_ subscriptions: [Subscription], from today: Date, limit: Int, calendar: Calendar = .current) -> [UpcomingPayment] {
        let start = calendar.startOfDay(for: today)
        guard let horizon = calendar.date(byAdding: .day, value: 62, to: start) else { return [] }
        let payments = subscriptions.filter { $0.status == .active }.flatMap { subscription in
            subscription.schedule.payments(from: start, to: horizon, in: calendar).prefix(limit).map { day in
                UpcomingPayment(name: subscription.name, day: day, price: subscription.price(on: day, calendar: calendar), currencyCode: subscription.currencyCode)
            }
        }
        return Array(payments.sorted { ($0.day, $0.name) < ($1.day, $1.name) }.prefix(limit))
    }
}
