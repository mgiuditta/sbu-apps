import SwiftUI

/// The billing cycle: the usual ones, or every N days, weeks, months or years.
struct CyclePicker: View {
    @Binding var draft: SubscriptionDraft

    var body: some View {
        Picker("Ciclo", selection: $draft.cycleChoice) {
            Text("Settimanale").tag(CycleChoice.weekly)
            Text("Mensile").tag(CycleChoice.monthly)
            Text("Ogni 3 mesi").tag(CycleChoice.quarterly)
            Text("Annuale").tag(CycleChoice.yearly)
            Text("Personalizzato").tag(CycleChoice.custom)
            Text("Una tantum").tag(CycleChoice.once)
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
    }
}
