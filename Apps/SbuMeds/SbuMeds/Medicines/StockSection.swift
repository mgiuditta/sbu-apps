import SbuKit
import SwiftUI

/// The stock: how many are left, counted down at each dose taken, and when to say it's time to refill.
struct StockSection: View {
    @Binding var draft: MedicineDraft

    var body: some View {
        Section {
            Toggle("Conta le scorte", isOn: $draft.tracksStock)
                .accessibilityIdentifier("tracksStock")
            if draft.tracksStock {
                Stepper(value: $draft.stock, in: 0...MedicineDraft.maxStock, step: draft.form.step) {
                    LabeledContent("Rimaste") {
                        Text(verbatim: draft.form.amountText(draft.stock))
                            .monospacedDigit()
                    }
                }
                Stepper(value: $draft.refillThreshold, in: 0...MedicineDraft.maxStock, step: draft.form.step) {
                    LabeledContent("Avvisami sotto") {
                        Text(verbatim: draft.form.amountText(draft.refillThreshold))
                            .monospacedDigit()
                    }
                }
            }
        } header: {
            Text("Scorte")
        } footer: {
            Text("Ogni dose presa scala le scorte; quando scendono alla soglia, un promemoria ti dice di ricomprarlo.")
        }
    }
}

#Preview("Light") {
    StockSectionPreview()
}

#Preview("Dark") {
    StockSectionPreview()
        .preferredColorScheme(.dark)
}

private struct StockSectionPreview: View {
    @State private var draft: MedicineDraft = {
        var draft = MedicineDraft(today: Day(.now, calendar: .current), calendar: .current)
        draft.tracksStock = true
        return draft
    }()

    var body: some View {
        Form {
            StockSection(draft: $draft)
        }
        .environment(\.sbuAccent, .meds)
    }
}
