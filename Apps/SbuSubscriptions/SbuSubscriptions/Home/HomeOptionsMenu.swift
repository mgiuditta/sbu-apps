import SbuKit
import SwiftData
import SwiftUI

/// The toolbar menu that sorts, groups and filters the home; it shows filled while a filter is on.
struct HomeOptionsMenu: View {
    @Binding var sort: HomeSort
    @Binding var grouping: HomeGrouping
    @Binding var list: String
    @Binding var category: String
    @Binding var paymentMethod: String
    let subscriptions: [Subscription]

    @Query(sort: \SubscriptionList.order) private var lists: [SubscriptionList]

    var body: some View {
        Menu {
            // Grouped by state, the order is on the Attivi header; by cycle or category there is no such header.
            if grouping != .status {
                Picker("Ordina per", selection: $sort) {
                    Text("Prossimo pagamento").tag(HomeSort.nextPayment)
                    Text("Prezzo al mese").tag(HomeSort.monthlyPrice)
                    Text("Nome").tag(HomeSort.name)
                }
                .pickerStyle(.menu)
            }
            Picker("Raggruppa per", selection: $grouping) {
                Text("Stato").tag(HomeGrouping.status)
                Text("Ciclo").tag(HomeGrouping.cycle)
                Text("Categoria").tag(HomeGrouping.category)
            }
            .pickerStyle(.menu)
            if !lists.isEmpty {
                Picker("Lista", selection: $list) {
                    Text("Tutte").tag("")
                    ForEach(lists) { Text($0.name).tag($0.name) }
                }
                .pickerStyle(.menu)
            }
            Picker("Categoria", selection: $category) {
                Text("Tutte").tag("")
                ForEach(usedCategories, id: \.self) { Text($0).tag($0) }
            }
            .pickerStyle(.menu)
            if !usedMethods.isEmpty {
                Picker("Metodo di pagamento", selection: $paymentMethod) {
                    Text("Tutti").tag("")
                    ForEach(usedMethods, id: \.self) { Text($0).tag($0) }
                }
                .pickerStyle(.menu)
            }
            if isFiltering {
                Button("Mostra tutti", systemImage: "xmark") {
                    list = ""
                    category = ""
                    paymentMethod = ""
                }
            }
        } label: {
            Label("Ordina e filtra", systemImage: isFiltering ? "line.3.horizontal.decrease.circle.fill" : "line.3.horizontal.decrease.circle")
        }
        .tint(SbuTheme.ink)
        .accessibilityIdentifier("options")
    }

    private var isFiltering: Bool { !list.isEmpty || !category.isEmpty || !paymentMethod.isEmpty }

    private var usedCategories: [String] {
        Set(subscriptions.compactMap { $0.category?.name }).sorted { $0.localizedStandardCompare($1) == .orderedAscending }
    }

    private var usedMethods: [String] {
        Set(subscriptions.map(\.paymentMethod).filter { !$0.isEmpty }).sorted { $0.localizedStandardCompare($1) == .orderedAscending }
    }
}
