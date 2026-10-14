import AppIntents
import SwiftData

/// "Quanto pago questo mese?": the month's payments and what's still to come, in the main currency.
struct MonthSpendingIntent: AppIntent {
    static let title: LocalizedStringResource = "Spesa del mese"
    static let description = IntentDescription("Dice quanto paghi questo mese e quanto resta da pagare.")

    @Dependency private var container: ModelContainer

    @MainActor
    func perform() async throws -> some IntentResult & ReturnsValue<Double> & ProvidesDialog {
        let currency = CurrencySettings()
        let calendar = Calendar.current
        let subscriptions = try ModelContext(container).fetch(FetchDescriptor<Subscription>())
        let month = MonthPayments(subscriptions, in: MonthGrid(containing: .now, calendar: calendar), today: .now,
                                  mainCurrency: currency.mainCurrency, converter: currency.converter, calendar: calendar)
        let total = month.total.formatted(.currency(code: currency.mainCurrency))
        let remaining = month.remaining.formatted(.currency(code: currency.mainCurrency))
        return .result(value: NSDecimalNumber(decimal: month.total).doubleValue,
                       dialog: "Questo mese paghi \(total). Ancora da pagare: \(remaining).")
    }
}
