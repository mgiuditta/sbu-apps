import SbuKit
import SwiftData
import SwiftUI

/// The + sheet: search the catalog of known services, or start a subscription of your own.
struct AddSubscriptionSheet: View {
    let currency: CurrencySettings

    @Environment(\.dismiss) private var dismiss
    @Query(sort: \SubscriptionCategory.order) private var categories: [SubscriptionCategory]
    @State private var query = ""

    var body: some View {
        NavigationStack {
            List {
                Section {
                    NavigationLink(value: AddRoute.custom) {
                        Label(query.isEmpty ? String(localized: "Personalizzato") : String(localized: "Aggiungi «\(query)»"), systemImage: "square.and.pencil")
                    }
                    .accessibilityIdentifier("addCustom")
                }
                ForEach(sections, id: \.0) { category, services in
                    Section(category.name) {
                        ForEach(services) { service in
                            NavigationLink(value: AddRoute.service(service)) {
                                Label(service.name, systemImage: category.symbol)
                            }
                        }
                    }
                }
            }
            .searchable(text: $query, placement: .navigationBarDrawer(displayMode: .always), prompt: Text("Cerca un servizio"))
            .navigationTitle("Aggiungi")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Annulla") { dismiss() }
                }
            }
            .navigationDestination(for: AddRoute.self) { route in
                SubscriptionFormView(draft: draft(for: route), currency: currency) { dismiss() }
            }
        }
    }

    /// Catalog matches grouped by category, in the categories' order.
    private var sections: [(BuiltInCategory, [CatalogService])] {
        let matches = Dictionary(grouping: CatalogService.matching(query), by: \.category)
        return BuiltInCategory.allCases.compactMap { category in
            matches[category].map { (category, $0) }
        }
    }

    private func draft(for route: AddRoute) -> SubscriptionDraft {
        switch route {
        case .custom:
            var draft = SubscriptionDraft(currencyCode: currency.mainCurrency)
            draft.name = query.trimmingCharacters(in: .whitespaces)
            return draft
        case let .service(service):
            return SubscriptionDraft(service: service, categories: categories, currencyCode: currency.mainCurrency)
        }
    }
}

#Preview("Light") {
    AddSubscriptionSheet(currency: CurrencySettings())
        .modelContainer(.preview)
}

#Preview("Dark") {
    AddSubscriptionSheet(currency: CurrencySettings())
        .modelContainer(.preview)
        .preferredColorScheme(.dark)
}
