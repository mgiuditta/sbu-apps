import Foundation
import SwiftData
import WidgetKit

/// Reads the app's store from the App Group, read-only, and plans a refresh at midnight; the app also
/// reloads the widget after every save.
struct SubscriptionsTimelineProvider: AppIntentTimelineProvider {
    func placeholder(in context: Context) -> SubscriptionsWidgetEntry {
        .sample()
    }

    func snapshot(for configuration: ChooseListIntent, in context: Context) async -> SubscriptionsWidgetEntry {
        if context.isPreview { return .sample() }
        return await entry(for: configuration, date: .now)
    }

    func timeline(for configuration: ChooseListIntent, in context: Context) async -> Timeline<SubscriptionsWidgetEntry> {
        let now = Date.now
        let entry = await entry(for: configuration, date: now)
        let calendar = Calendar.current
        let midnight = calendar.date(byAdding: .day, value: 1, to: calendar.startOfDay(for: now)) ?? now.addingTimeInterval(86_400)
        return Timeline(entries: [entry], policy: .after(midnight))
    }

    @MainActor
    private func entry(for configuration: ChooseListIntent, date: Date) -> SubscriptionsWidgetEntry {
        let calendar = Calendar.current
        let currency = CurrencySettings()
        let period = UserDefaults.appGroup.string(forKey: TotalPeriod.storageKey).flatMap(TotalPeriod.init(rawValue:)) ?? .year
        guard let container = try? ModelContainer.subscriptions(syncsWithICloud: false),
              var subscriptions = try? ModelContext(container).fetch(FetchDescriptor<Subscription>()) else {
            return SubscriptionsWidgetEntry(date: date, period: period, total: 0, monthRemaining: 0, currencyCode: currency.mainCurrency,
                                            upcoming: [], listName: nil, isEmpty: true)
        }
        let listName = configuration.list?.id
        if let listName { subscriptions = subscriptions.filter { $0.list?.name == listName } }
        let counted = subscriptions.filter { $0.countsInTotal(on: date, in: calendar) }
        let total = SpendingTotal(counted.map(\.charge), per: period, in: currency.mainCurrency, converter: currency.converter)
        let month = MonthPayments(subscriptions, in: MonthGrid(containing: date, calendar: calendar), today: date,
                                  mainCurrency: currency.mainCurrency, converter: currency.converter, calendar: calendar)
        return SubscriptionsWidgetEntry(
            date: date, period: period, total: total.amount, monthRemaining: month.remaining, currencyCode: currency.mainCurrency,
            upcoming: UpcomingPayments.next(subscriptions, from: date, limit: 6, calendar: calendar),
            listName: listName, isEmpty: subscriptions.isEmpty
        )
    }
}
