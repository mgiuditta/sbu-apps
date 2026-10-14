import SwiftUI

/// The reminder of one subscription: on or off, and how many days before the payment, from the day itself to a month.
struct ReminderPicker: View {
    @Binding var daysBefore: Int?

    /// The days kept while the reminder is off, so turning it back on restores them.
    @State private var lastDays = 1

    var body: some View {
        Toggle("Promemoria", isOn: isOn)
        if let days = daysBefore {
            Stepper(value: daysBinding(days), in: 0...30) {
                if days == 0 {
                    Text("Il giorno stesso")
                } else {
                    Text("^[\(days) giorno](inflect: true) prima")
                }
            }
        }
    }

    private var isOn: Binding<Bool> {
        Binding {
            daysBefore != nil
        } set: { on in
            if on {
                daysBefore = lastDays
            } else {
                if let daysBefore { lastDays = daysBefore }
                daysBefore = nil
            }
        }
    }

    private func daysBinding(_ days: Int) -> Binding<Int> {
        Binding { days } set: { daysBefore = $0 }
    }
}

#Preview("Light") {
    @Previewable @State var days: Int? = 3
    Form { ReminderPicker(daysBefore: $days) }
}

#Preview("Dark") {
    @Previewable @State var days: Int? = nil
    Form { ReminderPicker(daysBefore: $days) }
        .preferredColorScheme(.dark)
}
