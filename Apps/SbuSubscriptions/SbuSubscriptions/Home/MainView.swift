import SbuKit
import SwiftData
import SwiftUI

/// The home: the yearly (or monthly) total, then every subscription by section.
struct MainView: View {
    let currency: CurrencySettings

    @Query private var subscriptions: [Subscription]
    @AppStorage(TotalPeriod.storageKey, store: .appGroup) private var period = TotalPeriod.year
    @AppStorage("home.sort") private var sort = HomeSort.nextPayment
    @AppStorage("home.grouping") private var grouping = HomeGrouping.status
    @AppStorage("home.filter.list") private var listFilter = ""
    @AppStorage("home.filter.category") private var categoryFilter = ""
    @AppStorage("home.filter.paymentMethod") private var methodFilter = ""
    @State private var isAdding = false
    @State private var search = ""
    @State private var showsCalendar = false
    @State private var opened: Subscription?
    @Environment(AppRouter.self) private var router
    @Environment(ReceivedLists.self) private var received

    var body: some View {
        // ponytail: "today" is read on each render, not at midnight; the app redraws whenever it comes back.
        let today = Date.now
        let filter = HomeFilter(list: listFilter, category: categoryFilter, paymentMethod: methodFilter)
        let shown = subscriptions.filter { filter.matches($0) }
        let figureGroups = SubscriptionGroups(shown, on: today)
        let groups = SubscriptionGroups(shown.filter(matchesSearch), on: today, sort: sort, monthlyPrice: monthlyPrice)
        List {
            if !subscriptions.isEmpty, search.isEmpty {
                Section {
                    SpendingFigure(
                        total: total(figureGroups.counted, per: period),
                        otherTotal: total(figureGroups.counted, per: period.other),
                        period: period,
                        filterName: [listFilter, categoryFilter, methodFilter].first { !$0.isEmpty },
                        currency: currency
                    )
                    .listRowInsets(EdgeInsets())
                    .listRowBackground(Color.clear)
                }
                Section {
                    // A row, not a toolbar button: with + and the filters the title would no longer fit.
                    NavigationLink {
                        PaymentsCalendarView(currency: currency)
                    } label: {
                        Label {
                            Text("Calendario dei pagamenti")
                        } icon: {
                            // Not the accent: on this screen it belongs to the figure's full stop.
                            Image(systemName: "calendar")
                                .fontWeight(.medium)
                                .foregroundStyle(SbuTheme.inkMuted)
                        }
                    }
                    .accessibilityIdentifier("calendar")
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
            ForEach(HomeSections.groups(groups.active, by: grouping)) { group in
                Section(group.title) {
                    rows(group.subscriptions, today: today)
                }
            }
            CollapsedSection(title: "In pausa", subscriptions: groups.paused, today: today)
            CollapsedSection(title: "Annullati", subscriptions: groups.cancelled, today: today)
            CollapsedSection(title: "Conclusi", subscriptions: groups.finished, today: today)
            ReceivedListsSection(received: received, currency: currency, period: period)
        }
        .listStyle(.insetGrouped)
        .listSectionSpacing(.compact)
        .scrollContentBackground(.hidden)
        .searchable(text: $search, prompt: Text("Cerca"))
        .overlay {
            if !subscriptions.isEmpty, !search.isEmpty, groups.isEmpty {
                ContentUnavailableView.search(text: search)
            } else if !subscriptions.isEmpty, shown.isEmpty {
                ContentUnavailableView {
                    Label("Nessun abbonamento con questo filtro", systemImage: "line.3.horizontal.decrease.circle")
                } actions: {
                    Button("Mostra tutti", action: clearFilters)
                }
            }
            if subscriptions.isEmpty, received.lists.isEmpty {
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
                if !subscriptions.isEmpty {
                    HomeOptionsMenu(sort: $sort, grouping: $grouping, list: $listFilter, category: $categoryFilter,
                                    paymentMethod: $methodFilter, subscriptions: subscriptions)
                }
            }
        }
        .navigationDestination(for: Subscription.self) { subscription in
            SubscriptionDetailView(subscription: subscription, currency: currency)
        }
        .navigationDestination(item: $opened) { subscription in
            SubscriptionDetailView(subscription: subscription, currency: currency)
        }
        .navigationDestination(isPresented: $showsCalendar) {
            PaymentsCalendarView(currency: currency)
        }
        .onChange(of: router.pending, initial: true) {
            follow(router.pending)
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

    /// Follows a route from Siri, Shortcuts or Spotlight, once.
    private func follow(_ route: AppRoute?) {
        guard let route else { return }
        router.pending = nil
        switch route {
        case let .subscription(id): opened = subscriptions.first { $0.uuid == id }
        case .calendar: showsCalendar = true
        case .add: isAdding = true
        }
    }

    private func clearFilters() {
        listFilter = ""
        categoryFilter = ""
        methodFilter = ""
    }

    private func matchesSearch(_ subscription: Subscription) -> Bool {
        search.isEmpty || subscription.name.localizedStandardContains(search)
    }

    private func monthlyPrice(_ subscription: Subscription) -> Decimal? {
        subscription.charge.amount(per: .month).flatMap { currency.converter.convert($0, from: subscription.currencyCode, to: currency.mainCurrency) }
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
        .environment(AppRouter())
        .environment(ReceivedLists(store: ReceivedListsStore(url: .temporaryDirectory.appending(path: "preview.json")), inbox: nil))
}

#Preview("Dark") {
    NavigationStack { MainView(currency: CurrencySettings()) }
        .modelContainer(.preview)
        .environment(AppRouter())
        .environment(ReceivedLists(store: ReceivedListsStore(url: .temporaryDirectory.appending(path: "preview.json")), inbox: nil))
        .preferredColorScheme(.dark)
}
