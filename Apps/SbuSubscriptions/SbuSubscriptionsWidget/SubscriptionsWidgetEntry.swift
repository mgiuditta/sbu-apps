import Foundation
import WidgetKit

/// What the widget shows: the total for the chosen period, what's left this month, and the next payments.
struct SubscriptionsWidgetEntry: TimelineEntry {
    let date: Date
    var period: TotalPeriod
    var total: Decimal
    var monthRemaining: Decimal
    var currencyCode: String
    var upcoming: [UpcomingPayment]
    var listName: String?
    var isEmpty: Bool

    /// For the gallery and the placeholder: made-up, never the user's own.
    static func sample(date: Date = .now) -> SubscriptionsWidgetEntry {
        let calendar = Calendar.current
        func day(_ offset: Int) -> Date { calendar.date(byAdding: .day, value: offset, to: calendar.startOfDay(for: date)) ?? date }
        return SubscriptionsWidgetEntry(
            date: date, period: .year, total: Decimal(string: "544.34")!, monthRemaining: Decimal(string: "27.97")!, currencyCode: "EUR",
            upcoming: [
                UpcomingPayment(name: "Musica", day: day(1), price: Decimal(string: "10.99")!, currencyCode: "EUR"),
                UpcomingPayment(name: "Archivio cloud", day: day(4), price: Decimal(string: "2.99")!, currencyCode: "EUR"),
                UpcomingPayment(name: "Film e serie", day: day(9), price: Decimal(string: "13.99")!, currencyCode: "EUR"),
            ],
            listName: nil, isEmpty: false
        )
    }
}
