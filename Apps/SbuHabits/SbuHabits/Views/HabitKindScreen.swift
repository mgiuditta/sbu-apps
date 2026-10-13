import SbuKit
import SwiftUI

/// The form's Tipo screen: to do, timed or to avoid, with what each means.
struct HabitKindScreen: View {
    @Binding var draft: HabitDraft
    /// `HabitKind.choices`: Da evitare only when adding.
    let choices: [HabitKind]

    var body: some View {
        Form {
            Section {
                Picker("Tipo", selection: $draft.kind) {
                    ForEach(choices, id: \.self) { kind in
                        Text(kind.title)
                            .tag(kind)
                    }
                }
                .pickerStyle(.inline)
                .labelsHidden()
                .onChange(of: draft.kind, askForNotifications)
            } footer: {
                HabitKindFooter(kind: draft.kind, linksHealth: draft.linksHealth)
            }
        }
        .scrollContentBackground(.hidden)
        .background(SbuTheme.surface)
        .navigationTitle("Tipo")
        .navigationBarTitleDisplayMode(.inline)
    }

    /// The end of a countdown comes as a notification: iOS asks only the first time.
    private func askForNotifications() {
        if draft.kind == .timed {
            Task {
                _ = await ReminderScheduler.requestAuthorization()
            }
        }
    }
}

#Preview("Light") {
    HabitKindScreenPreview()
}

#Preview("Dark") {
    HabitKindScreenPreview()
        .preferredColorScheme(.dark)
}

private struct HabitKindScreenPreview: View {
    @State private var draft = HabitDraft(habit: nil, today: LogicalDay(.now))

    var body: some View {
        NavigationStack {
            HabitKindScreen(draft: $draft, choices: HabitKind.allCases)
        }
        .tint(SbuTheme.accentHabits)
    }
}
