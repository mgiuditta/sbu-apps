import Foundation

/// A 1.0 subscription turned into 2.0 values, before it reaches the store.
nonisolated struct LegacySubscription: Equatable, Sendable {
    var legacyID: Int
    var name: String
    var price: Decimal
    var currencyCode: String
    var cycle: BillingCycle
    var startDate: Date
    var trialEndDate: Date?
    var reminderDaysBefore: Int?
    /// The built-in category it matches, or the 1.0's label when none does.
    var category: BuiltInCategory?
    var customCategory: String?
    var serviceID: String?
    var notes: String
    var createdAt: Date
}

/// Converts the 1.0's rows. Pure, so each rule is tested on its own (ADR-0010).
nonisolated enum LegacyConversion {
    enum Failure: Error, Equatable {
        case badDate(String)
        case unknownCycle(String)
        case badAmount
        case noName
    }

    static func convert(_ row: LegacyRow, serviceIDs: Set<String>, calendar: Calendar) throws(Failure) -> LegacySubscription {
        let name = row.name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !name.isEmpty else { throw .noName }
        guard row.amount.isFinite, row.amount >= 0 else { throw .badAmount }
        let cycle: BillingCycle = switch row.billingCycle {
        case "weekly": .weekly
        case "monthly": .monthly
        case "quarterly": .every(3, .month)
        case "yearly": .yearly
        default: throw .unknownCycle(row.billingCycle)
        }
        let nextRenewal = try day(row.nextRenewalDate, calendar: calendar)
        var trialEnd: Date?
        if row.isTrial, let text = row.trialEndsAt {
            trialEnd = try day(text, calendar: calendar)
        }
        let category = row.category.flatMap(BuiltInCategory.init(legacyLabel:))
        let createdAt = (try? date(row.createdAt)) ?? .now
        return LegacySubscription(
            legacyID: row.id,
            name: name,
            price: price(row.amount),
            currencyCode: row.currency.uppercased(),
            cycle: cycle,
            // The first payment after the trial is the day it ends; otherwise the 1.0's next renewal.
            startDate: trialEnd ?? nextRenewal,
            trialEndDate: trialEnd,
            reminderDaysBefore: row.reminderDaysBefore < 0 ? nil : row.reminderDaysBefore,
            category: category,
            customCategory: category == nil ? row.category.map { $0.trimmingCharacters(in: .whitespaces) }.flatMap { $0.isEmpty ? nil : $0 } : nil,
            serviceID: row.iconSlug.flatMap { serviceIDs.contains($0) ? $0 : nil },
            notes: row.notes ?? "",
            createdAt: createdAt
        )
    }

    /// The 1.0 kept money as a double (9.99 might be 9.9900000001): two decimals hold every price it could show.
    static func price(_ amount: Double) -> Decimal {
        var value = Decimal(amount)
        var rounded = Decimal()
        NSDecimalRound(&rounded, &value, 2, .plain)
        return rounded
    }

    /// The 1.0 wrote local midnight as UTC (`toISOString`), so 15 June in Rome is "2026-06-14T22:00:00.000Z":
    /// read back in the device's time zone, it is the 15th again.
    static func day(_ text: String, calendar: Calendar) throws(Failure) -> Date {
        guard let instant = try? date(text) else { throw .badDate(text) }
        return calendar.startOfDay(for: instant)
    }

    private static func date(_ text: String) throws -> Date {
        if let date = try? Date(text, strategy: Date.ISO8601FormatStyle(includingFractionalSeconds: true)) { return date }
        return try Date(text, strategy: Date.ISO8601FormatStyle())
    }
}
