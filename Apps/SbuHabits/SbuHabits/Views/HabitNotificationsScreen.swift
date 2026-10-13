import SbuKit
import SwiftUI

/// The form's Notifiche screen: the habit's ring and title, then its reminder times.
struct HabitNotificationsScreen: View {
    let draft: HabitDraft
    @Binding var reminders: [RemindersSection.Row]

    var body: some View {
        Form {
            Section {
                HabitPreview(draft: draft, ringSize: SbuTheme.space12 * 2, symbolFont: SbuTheme.title2)
            }
            .listRowBackground(Color.clear)

            RemindersSection(rows: $reminders)
        }
        .scrollContentBackground(.hidden)
        .background(SbuTheme.surface)
        .navigationTitle("Notifiche")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview("Light") {
    HabitNotificationsScreenPreview()
}

#Preview("Dark") {
    HabitNotificationsScreenPreview()
        .preferredColorScheme(.dark)
}

private struct HabitNotificationsScreenPreview: View {
    @State private var reminders = [RemindersSection.Row(time: .now)]

    var body: some View {
        NavigationStack {
            HabitNotificationsScreen(draft: HabitDraft(habit: nil, today: LogicalDay(.now)), reminders: $reminders)
        }
        .tint(SbuTheme.accentHabits)
    }
}
