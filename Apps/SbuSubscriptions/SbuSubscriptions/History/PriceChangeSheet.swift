import SbuKit
import SwiftUI

/// A new price and the day it starts: today for a change already on your statement, or a later renewal.
struct PriceChangeSheet: View {
    let subscription: Subscription

    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @State private var priceText = ""
    @State private var effectiveDate: Date

    init(subscription: Subscription) {
        self.subscription = subscription
        _effectiveDate = State(initialValue: subscription.nextPayment() ?? Calendar.current.startOfDay(for: .now))
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    LabeledContent("Nuovo prezzo") {
                        TextField(subscription.price.formatted(.number), text: $priceText)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                            .accessibilityIdentifier("newPrice")
                    }
                    DatePicker("Da quando", selection: $effectiveDate, displayedComponents: .date)
                } footer: {
                    Text("I pagamenti da quel giorno usano il nuovo prezzo, anche nel totale e nei promemoria.")
                }
            }
            .navigationTitle("Cambia prezzo")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Annulla") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Salva", action: save)
                        .disabled(price == nil)
                }
            }
        }
    }

    private var price: Decimal? {
        guard let value = try? Decimal(priceText.trimmingCharacters(in: .whitespaces), format: .number), value >= 0 else { return nil }
        return value
    }

    private func save() {
        guard let price else { return }
        subscription.changePrice(to: price, from: effectiveDate, in: modelContext)
        try? modelContext.save()
        dismiss()
    }
}
