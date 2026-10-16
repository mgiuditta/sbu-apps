import SbuKit
import SwiftUI

/// "Ricarica": how many you bought, added to what is left.
struct RefillSheet: View {
    let form: MedicineForm
    let refill: (Double) -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var quantity: Double = 30

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Stepper(value: $quantity, in: form.step...MedicineDraft.maxStock, step: form.step) {
                        Text(verbatim: form.amountText(quantity))
                            .monospacedDigit()
                    }
                    .accessibilityIdentifier("refillQuantity")
                } footer: {
                    Text("Si aggiungono alle scorte rimaste.")
                }
            }
            .listRowBackground(SbuTheme.surfaceRaised)
            .scrollContentBackground(.hidden)
            .background(SbuTheme.surface)
            .navigationTitle("Ricarica")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Annulla", action: cancel)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Aggiungi", action: confirm)
                        .accessibilityIdentifier("confirmRefill")
                }
            }
        }
        .presentationDetents([.medium])
    }

    private func cancel() {
        dismiss()
    }

    private func confirm() {
        refill(quantity)
        dismiss()
    }
}

#Preview("Light") {
    RefillSheet(form: .tablet) { _ in }
        .tint(SbuTheme.accentMeds)
}

#Preview("Dark") {
    RefillSheet(form: .tablet) { _ in }
        .tint(SbuTheme.accentMeds)
        .preferredColorScheme(.dark)
}
