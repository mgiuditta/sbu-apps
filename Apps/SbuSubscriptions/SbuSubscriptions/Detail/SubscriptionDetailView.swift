import SbuKit
import SwiftData
import SwiftUI

/// One subscription in full: what you pay and when, how it's filed, and what you can do with it.
struct SubscriptionDetailView: View {
    let subscription: Subscription
    let currency: CurrencySettings

    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @State private var isEditing = false
    @State private var isDeleting = false
    @State private var isChangingPrice = false

    var body: some View {
        List {
            Section {
                LabeledContent("Prezzo") {
                    Text(subscription.price, format: .currency(code: subscription.currencyCode))
                        .foregroundStyle(SbuTheme.ink)
                }
                if let upcoming {
                    LabeledContent("Dal \(upcoming.effectiveDate.formatted(.dateTime.day().month(.wide)))") {
                        Text(upcoming.price, format: .currency(code: subscription.currencyCode))
                    }
                }
                LabeledContent("Ciclo") { Text(subscription.cycle.label) }
                if let count = subscription.paymentCount {
                    LabeledContent("Pagamenti", value: count, format: .number)
                }
                LabeledContent("Prossimo pagamento") { Text(nextPaymentText) }
                if let trialEnd = subscription.trialEndDate, subscription.isInTrial() {
                    LabeledContent("Prova fino al") { Text(trialEnd, format: .dateTime.day().month(.wide).year()) }
                }
                LabeledContent("Promemoria") { Text(reminderText) }
            }

            Section {
                LabeledContent("Categoria") {
                    if let category = subscription.category {
                        HStack(spacing: SbuTheme.space2) {
                            Image(systemName: category.symbol)
                                .fontWeight(.medium)
                                .imageScale(.medium)
                                .accessibilityHidden(true)
                            Text(category.name)
                        }
                    } else {
                        Text("Nessuna")
                    }
                }
                if let list = subscription.list {
                    LabeledContent("Lista", value: list.name)
                }
                if !subscription.paymentMethod.isEmpty {
                    LabeledContent("Metodo di pagamento", value: subscription.paymentMethod)
                }
                if let url = subscription.url, WebPage.isWebPage(url) {
                    Link(destination: url) {
                        LabeledContent("Sito") { Text(url.host() ?? url.absoluteString) }
                    }
                }
                if !subscription.notes.isEmpty {
                    Text(subscription.notes)
                }
            }

            Section {
                Button("Cambia prezzo") { isChangingPrice = true }
                NavigationLink("Cronologia") { HistoryView(subscription: subscription) }
            }

            CancelHelpSection(subscription: subscription)
            StatusActionsSection(subscription: subscription)

            Section {
                SbuButton("Elimina abbonamento", kind: .destructive, confirmationTitle: "Eliminare \(subscription.name)?", action: delete)
                    .accessibilityIdentifier("delete")
            }
        }
        .listStyle(.insetGrouped)
        .scrollContentBackground(.hidden)
        .background(SbuTheme.surface)
        .navigationTitle(subscription.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            Button("Modifica") { isEditing = true }
                .accessibilityIdentifier("edit")
        }
        // Deleted only once this screen is gone: a deleted model must never be read by a view on screen.
        .onDisappear {
            if isDeleting {
                modelContext.delete(subscription)
                try? modelContext.save()
            }
        }
        .sheet(isPresented: $isChangingPrice) {
            PriceChangeSheet(subscription: subscription)
        }
        .sheet(isPresented: $isEditing) {
            NavigationStack {
                SubscriptionFormView(draft: SubscriptionDraft(subscription: subscription), currency: currency, editing: subscription) {
                    isEditing = false
                }
            }
        }
    }

    /// The next price change still to come, if any.
    private var upcoming: PriceChange? {
        let today = Calendar.current.startOfDay(for: .now)
        return (subscription.priceChanges ?? []).filter { $0.effectiveDate > today }.min { $0.effectiveDate < $1.effectiveDate }
    }

    private var nextPaymentText: LocalizedStringKey {
        switch subscription.status {
        case .paused: return "In pausa"
        case .cancelled: return "Annullato"
        case .active: break
        }
        guard let next = subscription.nextPayment() else { return "Concluso" }
        return "\(next.formatted(.dateTime.day().month(.wide).year()))"
    }

    private var reminderText: LocalizedStringKey {
        switch subscription.reminderDaysBefore {
        case nil: "Nessuno"
        case 0: "Il giorno stesso"
        case let days?: "^[\(days) giorno](inflect: true) prima"
        }
    }

    private func delete() {
        isDeleting = true
        dismiss()
    }
}

#Preview("Light") {
    NavigationStack { SubscriptionDetailView(subscription: .preview, currency: CurrencySettings()) }
        .modelContainer(.preview)
}

#Preview("Dark") {
    NavigationStack { SubscriptionDetailView(subscription: .preview, currency: CurrencySettings()) }
        .modelContainer(.preview)
        .preferredColorScheme(.dark)
}
