import SbuKit
import SwiftUI

/// A row of the habit form: a symbol and a name, and the current value on the right.
struct HabitFormRow: View {
    let title: LocalizedStringResource
    let systemImage: String
    let value: String

    var body: some View {
        LabeledContent {
            Text(value)
                .foregroundStyle(SbuTheme.inkMuted)
        } label: {
            Label {
                Text(title)
                    .foregroundStyle(SbuTheme.ink)
            } icon: {
                Image(systemName: systemImage)
                    .fontWeight(.medium)
                    .imageScale(.medium)
                    .accessibilityHidden(true)
            }
        }
    }
}

#Preview("Light") {
    HabitFormRowPreview()
}

#Preview("Dark") {
    HabitFormRowPreview()
        .preferredColorScheme(.dark)
}

private struct HabitFormRowPreview: View {
    var body: some View {
        NavigationStack {
            Form {
                NavigationLink(value: HabitFormRoute.goal) {
                    HabitFormRow(title: "Obiettivo", systemImage: "target", value: "8000 passi")
                }
                NavigationLink(value: HabitFormRoute.days) {
                    HabitFormRow(title: "Giorni", systemImage: "calendar", value: "Ogni giorno")
                }
            }
        }
        .tint(SbuTheme.accentHabits)
    }
}
