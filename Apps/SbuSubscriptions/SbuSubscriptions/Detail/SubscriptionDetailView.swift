import SbuKit
import SwiftData
import SwiftUI

/// One subscription in full, in a sheet: name and price on top, what you pay and since when, how it's filed,
/// and what you can do with it.
struct SubscriptionDetailView: View {
    let subscription: Subscription
    let currency: CurrencySettings

    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @State private var isEditing = false
    @State private var isDeleting = false
    @State private var isChangingPrice = false
    @State private var showsHistory = false
    @State private var isClosing = false

    var body: some View {
        NavigationStack {
            List {
                Section {
                    DetailHeader(subscription: subscription, isClosing: $isClosing)
                        .listRowInsets(EdgeInsets())
                        .listRowBackground(Color.clear)
                }
                DetailFactsSection(subscription: subscription, tally: subscription.tally())
                PaymentHistorySection(subscription: subscription, edit: showHistory, markedPaid: closeOnPaid)
                PriceHistorySection(subscription: subscription, edit: changePrice)
                DetailMoreSection(subscription: subscription)
                PauseSection(subscription: subscription)
                StatusActionsSection(subscription: subscription, delete: delete)
                CancelHelpSection(subscription: subscription)
            }
            .listStyle(.insetGrouped)
            .scrollContentBackground(.hidden)
            .background(SbuTheme.paper)
            .navigationBarTitleDisplayMode(.inline)
            .navigationDestination(isPresented: $showsHistory) {
                HistoryView(subscription: subscription)
            }
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Modifica") { isEditing = true }
                        .accessibilityIdentifier("edit")
                }
            }
        }
        .presentationDragIndicator(.visible)
        // Deleted only once this sheet is gone: a deleted model must never be read by a view on screen.
        .onDisappear(perform: deleteIfAsked)
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

    private func showHistory() {
        showsHistory = true
    }

    private func closeOnPaid() {
        isClosing = true
    }

    private func changePrice() {
        isChangingPrice = true
    }

    private func delete() {
        isDeleting = true
        dismiss()
    }

    private func deleteIfAsked() {
        guard isDeleting else { return }
        modelContext.delete(subscription)
        try? modelContext.save()
    }
}

#Preview("Light") {
    Color.clear
        .sheet(isPresented: .constant(true)) {
            SubscriptionDetailView(subscription: .preview, currency: CurrencySettings())
        }
        .modelContainer(.preview)
}

#Preview("Dark") {
    Color.clear
        .sheet(isPresented: .constant(true)) {
            SubscriptionDetailView(subscription: .preview, currency: CurrencySettings())
        }
        .modelContainer(.preview)
        .preferredColorScheme(.dark)
}
