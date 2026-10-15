import SbuKit
import SwiftData
import SwiftUI

/// The Regali cover: a real gift list, closed by what is still to spend.
struct GiftsView: View {
    @Query(sort: \Gift.createdAt, order: .reverse) private var gifts: [Gift]
    @Environment(\.modelContext) private var modelContext
    @State private var search = ""
    @State private var isAdding = false
    @State private var opened: Gift?

    private let currencyCode = Locale.current.currency?.identifier ?? "EUR"

    var body: some View {
        let shown = gifts.filter(matchesSearch)
        let total = GiftTotal(gifts.map { ($0.price, $0.isBought) })
        List {
            if !gifts.isEmpty, search.isEmpty {
                Section {
                    SbuToolField(
                        "Da spendere",
                        value: total.amount,
                        format: .currency(code: currencyCode),
                        context: "^[\(total.count) regalo](inflect: true) da comprare"
                    ) {
                        EmptyView()
                    } pills: {
                        EmptyView()
                    }
                    .listRowInsets(EdgeInsets())
                    .listRowBackground(Color.clear)
                }
            }
            section("Da comprare", shown.filter { !$0.isBought })
            section("Comprati", shown.filter(\.isBought))
        }
        .listStyle(.insetGrouped)
        .scrollContentBackground(.hidden)
        .searchable(text: $search, prompt: Text("Cerca"))
        .overlay {
            if gifts.isEmpty {
                ContentUnavailableView {
                    Label("Nessun regalo", systemImage: "gift")
                } description: {
                    Text("Le idee regalo che aggiungi compaiono qui, con quanto ti resta da spendere.")
                } actions: {
                    SbuButton("Aggiungi") { isAdding = true }
                        .accessibilityIdentifier("addFirst")
                }
            } else if !search.isEmpty, shown.isEmpty {
                ContentUnavailableView.search(text: search)
            }
        }
        .toolbar {
            // In ink: on this screen the accent belongs to the figure's full stop.
            ToolbarItem(placement: .topBarLeading) {
                Button("Aggiungi regalo", systemImage: "plus") { isAdding = true }
                    .tint(SbuTheme.ink)
                    .accessibilityIdentifier("add")
            }
        }
        .sheet(isPresented: $isAdding) {
            GiftFormView(currencyCode: currencyCode)
        }
        .sheet(item: $opened) { gift in
            GiftFormView(editing: gift, currencyCode: currencyCode)
        }
    }

    @ViewBuilder
    private func section(_ title: LocalizedStringKey, _ gifts: [Gift]) -> some View {
        if !gifts.isEmpty {
            Section(title) {
                ForEach(gifts) { gift in
                    Button {
                        opened = gift
                    } label: {
                        GiftRow(gift: gift, currencyCode: currencyCode)
                    }
                    .swipeActions(edge: .leading) {
                        Button(gift.isBought ? "Da comprare" : "Comprato", systemImage: gift.isBought ? "arrow.uturn.backward" : "checkmark") {
                            gift.isBought.toggle()
                        }
                        .tint(SbuTheme.accentDuo)
                    }
                    .swipeActions(edge: .trailing) {
                        Button("Elimina", systemImage: "trash", role: .destructive) {
                            modelContext.delete(gift)
                        }
                    }
                }
            }
        }
    }

    private func matchesSearch(_ gift: Gift) -> Bool {
        search.isEmpty || gift.idea.localizedStandardContains(search) || gift.person.localizedStandardContains(search)
    }
}

#Preview("Light") {
    NavigationStack { GiftsView() }
        .modelContainer(.duoPreview)
}

#Preview("Dark") {
    NavigationStack { GiftsView() }
        .modelContainer(.duoPreview)
        .preferredColorScheme(.dark)
}
