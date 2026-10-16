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
    /// The cycle or category sections folded, by title.
    @State private var collapsed: Set<String> = []
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
                if grouping == .status {
                    Section(group.title) {
                        rows(group.subscriptions, today: today)
                    }
                } else {
                    Section {
                        if !collapsed.contains(group.title) {
                            rows(group.subscriptions, today: today)
                        }
                    } header: {
                        CollapsibleHeader(title: group.title, count: group.subscriptions.count, isCollapsed: isCollapsed(group.title))
                    }
                }
            }
            CollapsedSection(title: "In pausa", subscriptions: groups.paused, today: today, open: open)
            CollapsedSection(title: "Annullati", subscriptions: groups.cancelled, today: today, open: open)
            CollapsedSection(title: "Conclusi", subscriptions: groups.finished, today: today, open: open)
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
            // In ink: on this screen the accent belongs to the figure's full stop.
            if !subscriptions.isEmpty {
                ToolbarItem(placement: .topBarLeading) {
                    HomeOptionsMenu(sort: $sort, grouping: $grouping, list: $listFilter, category: $categoryFilter,
                                    paymentMethod: $methodFilter, subscriptions: subscriptions)
                }
            }
            ToolbarItem(placement: .topBarTrailing) {
                Button("Aggiungi abbonamento", systemImage: "plus") { isAdding = true }
                    .tint(SbuTheme.ink)
                    .accessibilityIdentifier("add")
            }
        }
        .sheet(item: $opened) { subscription in
            SubscriptionDetailView(subscription: subscription, currency: currency)
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
            SubscriptionButton(subscription: subscription, today: today, open: open)
        }
    }

    private func open(_ subscription: Subscription) {
        opened = subscription
    }

    private func isCollapsed(_ title: String) -> Binding<Bool> {
        Binding { collapsed.contains(title) } set: { if $0 { collapsed.insert(title) } else { collapsed.remove(title) } }
    }

    /// Follows a route from Siri, Shortcuts or Spotlight, once; the calendar is its own tab, which `RootView` selects.
    private func follow(_ route: AppRoute?) {
        switch route {
        case let .subscription(id):
            router.pending = nil
            opened = subscriptions.first { $0.uuid == id }
        case .add:
            router.pending = nil
            isAdding = true
        case .calendar, nil:
            break
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
