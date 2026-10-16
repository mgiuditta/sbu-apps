import SbuKit
import SwiftData
import SwiftUI

/// The payments month by month: what the month costs, what's still to pay, and who is paid on which day.
struct PaymentsCalendarView: View {
    let currency: CurrencySettings

    @Query private var subscriptions: [Subscription]
    @State private var grid = MonthGrid(containing: .now, calendar: .current)
    @State private var selected = Calendar.current.startOfDay(for: .now)
    @State private var addFrom: AddStart?
    @State private var opened: Subscription?
    @ScaledMetric(relativeTo: .title2) private var totalSize = SbuTheme.statSmallSize

    var body: some View {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: .now)
        let month = MonthPayments(subscriptions, in: grid, today: today, mainCurrency: currency.mainCurrency, converter: currency.converter, calendar: calendar)
        List {
            Section {
                MonthHeader(grid: grid, month: month, mainCurrency: currency.mainCurrency, totalSize: totalSize, changeMonth: changeMonth)
                MonthGridView(grid: grid, month: month, today: today, selected: $selected, changeMonth: changeMonth) { addFrom = AddStart(date: $0) }
            }
            Section {
                let payments = month.payments(on: selected)
                if payments.isEmpty {
                    Text("Nessun pagamento")
                        .foregroundStyle(SbuTheme.inkMuted)
                }
                ForEach(payments) { payment in
                    Button {
                        opened = payment.subscription
                    } label: {
                        // Not a LabeledContent: inside a button it stacked the price under the name.
                        HStack {
                            Text(payment.subscription.name)
                                .foregroundStyle(SbuTheme.ink)
                            Spacer()
                            Text(payment.subscription.price, format: .currency(code: payment.subscription.currencyCode))
                                .foregroundStyle(SbuTheme.inkMuted)
                        }
                    }
                }
            } header: {
                Text(selected, format: .dateTime.weekday(.wide).day().month(.wide))
            }
        }
        .listStyle(.insetGrouped)
        .scrollContentBackground(.hidden)
        .background(SbuTheme.surface)
        .sheet(item: $opened) { subscription in
            SubscriptionDetailView(subscription: subscription, currency: currency)
        }
        .sheet(item: $addFrom) { start in
            AddSubscriptionSheet(currency: currency, startDate: start.date)
        }
    }

    private func changeMonth(_ months: Int) {
        let calendar = Calendar.current
        grid = grid.adding(months: months, calendar: calendar)
        // The selection follows to the new month: today if it's there, else the 1st.
        let today = calendar.startOfDay(for: .now)
        selected = (grid.start..<grid.end).contains(today) ? today : grid.start
    }
}

/// The day a sheet adds from.
struct AddStart: Identifiable {
    let date: Date
    var id: Date { date }
}

#Preview("Light") {
    NavigationStack { PaymentsCalendarView(currency: CurrencySettings()) }
        .modelContainer(.preview)
}

#Preview("Dark") {
    NavigationStack { PaymentsCalendarView(currency: CurrencySettings()) }
        .modelContainer(.preview)
        .preferredColorScheme(.dark)
}
