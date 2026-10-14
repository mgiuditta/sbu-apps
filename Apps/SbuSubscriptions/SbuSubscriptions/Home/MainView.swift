import SbuKit
import SwiftData
import SwiftUI

/// The home: the yearly (or monthly) total, then every subscription by section.
struct MainView: View {
    let currency: CurrencySettings

    @Query private var subscriptions: [Subscription]
    @AppStorage(TotalPeriod.storageKey, store: .appGroup) private var period = TotalPeriod.year
    @State private var isAdding = false

    var body: some View {
        // ponytail: "today" is read on each render, not at midnight; the app redraws whenever it comes back.
        let today = Date.now
        let groups = SubscriptionGroups(subscriptions, on: today)
        List {
            if !subscriptions.isEmpty {
                Section {
                    SpendingFigure(
                        total: total(groups.counted, per: period),
                        otherTotal: total(groups.counted, per: period.other),
                        period: period,
                        currency: currency
                    )
                    .listRowInsets(EdgeInsets())
                    .listRowBackground(Color.clear)
                }
            }
            if !groups.trials.isEmpty {
                Section {
                    rows(groups.trials, today: today)
                } header: {
                    Text("Prove gratuite")
                } footer: {
                    Text(trialFooter(groups.trials))
                }
            }
            if !groups.active.isEmpty {
                Section("Attivi") {
                    rows(groups.active, today: today)
                }
            }
            CollapsedSection(title: "In pausa", subscriptions: groups.paused, today: today)
            CollapsedSection(title: "Annullati", subscriptions: groups.cancelled, today: today)
            CollapsedSection(title: "Conclusi", subscriptions: groups.finished, today: today)
        }
        .listStyle(.insetGrouped)
        .listSectionSpacing(.compact)
        .scrollContentBackground(.hidden)
        .overlay {
            if subscriptions.isEmpty {
                ContentUnavailableView {
                    Label("Nessun abbonamento", systemImage: "creditcard")
                } description: {
                    Text("Gli abbonamenti che aggiungi compaiono qui, con quanto spendi.")
                } actions: {
                    SbuButton("Aggiungi") { isAdding = true }
                        .accessibilityIdentifier("addFirst")
                }
            }
        }
        .toolbar {
            // In ink, like the gear: on this screen the accent belongs to the figure's full stop.
            ToolbarItemGroup(placement: .topBarLeading) {
                Button("Aggiungi abbonamento", systemImage: "plus") { isAdding = true }
                    .tint(SbuTheme.ink)
                    .accessibilityIdentifier("add")
                NavigationLink {
                    PaymentsCalendarView(currency: currency)
                } label: {
                    Label("Calendario", systemImage: "calendar")
                }
                .tint(SbuTheme.ink)
                .accessibilityIdentifier("calendar")
            }
        }
        .navigationDestination(for: Subscription.self) { subscription in
            SubscriptionDetailView(subscription: subscription, currency: currency)
        }
        .sheet(isPresented: $isAdding) {
            AddSubscriptionSheet(currency: currency)
        }
    }

    private func rows(_ subscriptions: [Subscription], today: Date) -> some View {
        ForEach(subscriptions) { subscription in
            NavigationLink(value: subscription) {
                SubscriptionRow(subscription: subscription, today: today)
            }
        }
    }

    private func total(_ subscriptions: [Subscription], per period: TotalPeriod) -> SpendingTotal {
        SpendingTotal(subscriptions.map(\.charge), per: period, in: currency.mainCurrency, converter: currency.converter)
    }

    private func trialFooter(_ trials: [Subscription]) -> LocalizedStringKey {
        let after = total(trials, per: period).amount.formatted(.currency(code: currency.mainCurrency))
        return period == .year ? "Dopo la prova: \(after) all'anno" : "Dopo la prova: \(after) al mese"
    }
}

#Preview("Light") {
    NavigationStack { MainView(currency: CurrencySettings()) }
        .modelContainer(.preview)
}

#Preview("Dark") {
    NavigationStack { MainView(currency: CurrencySettings()) }
        .modelContainer(.preview)
        .preferredColorScheme(.dark)
}
