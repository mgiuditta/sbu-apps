import SbuKit
import SwiftUI

/// What is left, the refill threshold, a word when it is low, and "Ricarica".
struct MedicineStockSection: View {
    let medicine: MedicineSnapshot
    let refill: () -> Void

    var body: some View {
        Section {
            LabeledContent("Rimaste") {
                Text(verbatim: medicine.form.amountText(medicine.stock ?? 0))
                    .monospacedDigit()
            }
            .accessibilityIdentifier("stock")
            if let threshold = medicine.refillThreshold {
                LabeledContent("Avvisami sotto") {
                    Text(verbatim: medicine.form.amountText(threshold))
                        .monospacedDigit()
                }
            }
            if medicine.stockLevel.isLow {
                Label("Scorte basse: ricompralo", systemImage: "exclamationmark.triangle")
                    .foregroundStyle(SbuTheme.warning)
            }
            Button("Ricarica", systemImage: "shippingbox", action: refill)
                .accessibilityIdentifier("refill")
        } header: {
            Text("Scorte")
        }
        .listRowBackground(SbuTheme.surfaceRaised)
    }
}

#Preview("Light") {
    MedicineStockSectionPreview()
}

#Preview("Dark") {
    MedicineStockSectionPreview()
        .preferredColorScheme(.dark)
}

private struct MedicineStockSectionPreview: View {
    var body: some View {
        let medicine = MedicineSnapshot(name: "Ramipril", schedule: Schedule(start: Day(.now, calendar: .current)), stock: 6, refillThreshold: 7)
        List {
            MedicineStockSection(medicine: medicine) {}
        }
        .listStyle(.insetGrouped)
        .scrollContentBackground(.hidden)
        .background(SbuTheme.paper)
        .environment(\.sbuAccent, .meds)
    }
}
