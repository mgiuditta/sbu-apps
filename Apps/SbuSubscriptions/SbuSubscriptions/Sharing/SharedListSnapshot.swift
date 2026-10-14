import Foundation

/// What people see of a shared list: its name and each subscription's price, cycle and dates.
/// Only these travel; notes, payment methods, websites and reminders never leave the owner's iPhone.
nonisolated struct SharedListSnapshot: Codable, Equatable, Sendable {
    static let currentVersion = 1

    nonisolated struct Item: Codable, Equatable, Sendable {
        var name: String
        var price: Decimal
        var currencyCode: String
        var cycle: BillingCycle
        var startDate: Date
        var paymentCount: Int? = nil
        var trialEndDate: Date? = nil
        var status: SubscriptionStatus

        var schedule: BillingSchedule {
            BillingSchedule(start: startDate, cycle: cycle, paymentCount: paymentCount)
        }

        /// The same rule as the owner's total: active, past its trial, not paid off, not one-off.
        func countsInTotal(on date: Date, calendar: Calendar) -> Bool {
            guard status == .active, cycle != .once else { return false }
            if let trialEndDate, calendar.startOfDay(for: date) < calendar.startOfDay(for: trialEndDate) { return false }
            return schedule.nextPayment(onOrAfter: date, in: calendar) != nil
        }
    }

    var version = currentVersion
    var name: String
    var items: [Item]

    func encoded() throws -> Data {
        try JSONEncoder().encode(self)
    }

    /// - Throws: when it comes from a newer Sbu Subscriptions: the copy already here stays.
    static func decode(_ data: Data) throws -> SharedListSnapshot {
        let snapshot = try JSONDecoder().decode(SharedListSnapshot.self, from: data)
        guard snapshot.version <= currentVersion else { throw DecodingError.dataCorrupted(.init(codingPath: [], debugDescription: "Newer snapshot")) }
        return snapshot
    }
}

extension SharedListSnapshot {
    /// The list as it is now, in name order, at today's prices.
    init(list: SubscriptionList, today: Date = .now) {
        name = list.name
        items = (list.subscriptions ?? [])
            .sorted { $0.name.localizedStandardCompare($1.name) == .orderedAscending }
            .map { subscription in
                Item(name: subscription.name, price: subscription.price(on: today), currencyCode: subscription.currencyCode,
                     cycle: subscription.cycle, startDate: subscription.startDate, paymentCount: subscription.paymentCount,
                     trialEndDate: subscription.trialEndDate, status: subscription.status)
            }
    }
}

extension SharedListSnapshot {
    /// Made up, for UI tests and previews.
    static var demo: SharedListSnapshot {
        let start = Calendar.current.date(byAdding: .day, value: -20, to: .now) ?? .now
        return SharedListSnapshot(name: String(localized: "Famiglia"), items: [
            Item(name: String(localized: "Film e serie"), price: Decimal(string: "17.99")!, currencyCode: "EUR", cycle: .monthly, startDate: start, status: .active),
            Item(name: String(localized: "Archivio cloud"), price: Decimal(string: "9.99")!, currencyCode: "EUR", cycle: .monthly, startDate: start, status: .active),
        ])
    }
}
