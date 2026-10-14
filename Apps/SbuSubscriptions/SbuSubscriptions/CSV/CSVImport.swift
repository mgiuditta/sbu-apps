import Foundation

/// A CSV file read into subscriptions to review: each row either becomes one, or says why it can't.
nonisolated struct CSVImport: Identifiable, Sendable {
    nonisolated struct Row: Identifiable, Sendable {
        let id: Int
        /// The line in the file, counting the header as 1, as a spreadsheet numbers it.
        var line: Int { id + 2 }
        var result: Result<Candidate, Problem>
    }

    nonisolated struct Candidate: Equatable, Sendable {
        var name: String
        var price: Decimal
        var currencyCode: String
        var cycle: BillingCycle
        var date: Date
        var trialEnd: Date?
        var category: String?
        var notes: String
        var status: SubscriptionStatus
        var reminderDaysBefore: Int?
        var list: String?
        var paymentMethod: String
        var website: URL?
    }

    nonisolated enum Problem: Error, Equatable, Sendable {
        case noName
        case badPrice(String)
        case badCycle(String)
        case badDate(String)
    }

    nonisolated enum Failure: Error, Equatable, Sendable {
        case empty
        /// Neither a name nor a price column: not a subscriptions file.
        case unknownColumns
    }

    let id = UUID()
    let rows: [Row]

    init(text: String, mainCurrency: String, today: Date, locale: Locale, calendar: Calendar) throws(Failure) {
        let table = CSVTable.rows(text)
        guard let header = table.first, table.count > 1 else { throw .empty }
        var columns: [CSVColumn: Int] = [:]
        for (index, title) in header.enumerated() {
            if let column = CSVColumn.match(title), columns[column] == nil { columns[column] = index }
        }
        guard columns[.name] != nil, columns[.price] != nil else { throw .unknownColumns }
        rows = table.dropFirst().enumerated().map { offset, fields in
            func value(_ column: CSVColumn) -> String? {
                guard let index = columns[column], index < fields.count else { return nil }
                let text = fields[index].trimmingCharacters(in: .whitespacesAndNewlines)
                return text.isEmpty ? nil : text
            }
            return Row(id: offset, result: Self.candidate(value, mainCurrency: mainCurrency, today: today, locale: locale, calendar: calendar))
        }
    }

    private static func candidate(_ value: (CSVColumn) -> String?, mainCurrency: String, today: Date, locale: Locale, calendar: Calendar) -> Result<Candidate, Problem> {
        guard let name = value(.name) else { return .failure(.noName) }
        guard let priceText = value(.price), let price = CSVValue.price(priceText) else { return .failure(.badPrice(value(.price) ?? "")) }
        var cycle = BillingCycle.monthly
        if let text = value(.cycle) {
            guard let parsed = CSVValue.cycle(text) else { return .failure(.badCycle(text)) }
            cycle = parsed
        }
        var date = calendar.startOfDay(for: today)
        if let text = value(.date) {
            guard let parsed = CSVValue.date(text, locale: locale, calendar: calendar) else { return .failure(.badDate(text)) }
            date = parsed
        }
        let isTrial = value(.trial).map(CSVValue.flag) ?? false
        let trialEnd = isTrial ? value(.trialEnd).flatMap { CSVValue.date($0, locale: locale, calendar: calendar) } : nil
        let status = value(.status).flatMap(SubscriptionStatus.init(rawValue:)) ?? .active
        let reminder: Int?? = value(.reminder).map { Int($0).flatMap { $0 < 0 ? nil : $0 } }
        let currency = value(.currency).map { $0.uppercased() }.flatMap { $0.count == 3 ? $0 : nil } ?? mainCurrency
        return .success(Candidate(
            name: name,
            price: price,
            currencyCode: currency,
            cycle: cycle,
            date: trialEnd ?? date,
            trialEnd: trialEnd,
            category: value(.category),
            notes: value(.notes) ?? "",
            status: status,
            reminderDaysBefore: reminder ?? 1,
            list: value(.list),
            paymentMethod: value(.paymentMethod) ?? "",
            website: value(.website).flatMap(WebPage.url)
        ))
    }
}
