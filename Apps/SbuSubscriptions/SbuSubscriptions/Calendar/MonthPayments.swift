import Foundation

/// The payments that fall in a month, by day, with what they add up to in the main currency.
struct MonthPayments {
    struct Payment: Identifiable {
        let subscription: Subscription
        let day: Date
        var id: String { "\(subscription.persistentModelID.hashValue)-\(day.timeIntervalSince1970)" }
    }

    private(set) var byDay: [Date: [Payment]] = [:]
    /// Every payment of the month, converted to the main currency.
    private(set) var total: Decimal = 0
    /// The ones from today on.
    private(set) var remaining: Decimal = 0
    /// Payments left out of the sums for lack of a rate.
    private(set) var missingRates = 0

    /// Paused and cancelled subscriptions pay nothing; a trial pays on the day it ends.
    init(_ subscriptions: [Subscription], in grid: MonthGrid, today: Date, mainCurrency: String, converter: CurrencyConverter, calendar: Calendar) {
        let today = calendar.startOfDay(for: today)
        for subscription in subscriptions where subscription.status == .active {
            for day in subscription.schedule.payments(from: grid.start, to: grid.end, in: calendar) {
                byDay[day, default: []].append(Payment(subscription: subscription, day: day))
                guard let amount = converter.convert(subscription.price(on: day, calendar: calendar), from: subscription.currencyCode, to: mainCurrency) else {
                    missingRates += 1
                    continue
                }
                total += amount
                if day >= today { remaining += amount }
            }
        }
        for day in byDay.keys {
            byDay[day]?.sort { $0.subscription.name.localizedStandardCompare($1.subscription.name) == .orderedAscending }
        }
    }

    func payments(on day: Date) -> [Payment] {
        byDay[day] ?? []
    }
}
