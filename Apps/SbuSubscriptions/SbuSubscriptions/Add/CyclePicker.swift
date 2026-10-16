import SwiftUI

/// How you pay, as the category's reference apps ask it: recurring or once, every how long, for how long,
/// and whether it starts with a free trial.
struct CyclePicker: View {
    @Binding var draft: SubscriptionDraft
    /// Editing counts the payments left; adding counts them all.
    let isEditing: Bool

    var body: some View {
        Picker("Tipo", selection: $draft.isRecurring) {
            Text("Ricorrente").tag(true)
            Text("Una tantum").tag(false)
        }
        if draft.isRecurring {
            Picker("Ciclo", selection: $draft.cycleChoice) {
                Text("Settimanale").tag(CycleChoice.weekly)
                Text("Mensile").tag(CycleChoice.monthly)
                Text("Ogni 3 mesi").tag(CycleChoice.quarterly)
                Text("Annuale").tag(CycleChoice.yearly)
                Text("Personalizzato").tag(CycleChoice.custom)
            }
            if draft.cycleChoice == .custom {
                Stepper(value: $draft.customInterval, in: 1...99) {
                    Text("Ogni \(draft.customInterval)")
                }
                Picker("Unità", selection: $draft.customUnit) {
                    Text("Giorni").tag(BillingUnit.day)
                    Text("Settimane").tag(BillingUnit.week)
                    Text("Mesi").tag(BillingUnit.month)
                    Text("Anni").tag(BillingUnit.year)
                }
                .pickerStyle(.segmented)
            }
            Picker("Durata", selection: $draft.hasFixedCount) {
                Text("Per sempre").tag(false)
                Text("Numero fisso di pagamenti").tag(true)
            }
            if draft.hasFixedCount {
                Stepper(value: $draft.paymentCount, in: 1...360) {
                    if isEditing {
                        Text("Pagamenti rimanenti: \(draft.paymentCount)")
                    } else {
                        Text("^[\(draft.paymentCount) pagamento](inflect: true)")
                    }
                }
            }
        }
        Toggle("Prova gratuita", isOn: $draft.hasTrial)
    }
}

#Preview("Light") {
    @Previewable @State var draft = SubscriptionDraft(currencyCode: "EUR")
    Form { CyclePicker(draft: $draft, isEditing: false) }
}

#Preview("Dark") {
    @Previewable @State var draft = SubscriptionDraft(currencyCode: "EUR")
    Form { CyclePicker(draft: $draft, isEditing: true) }
        .preferredColorScheme(.dark)
}
