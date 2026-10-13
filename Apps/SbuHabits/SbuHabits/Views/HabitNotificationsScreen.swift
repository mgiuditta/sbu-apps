import SbuKit
import SwiftUI

/// The form's Notifiche screen, as Streaks lays it out: the habit's ring and title; Promemoria
/// (none, automatic or custom times); for a habit Salute marks, whether a notification says so;
/// then Sensibili al tempo and Suono, while something notifies.
struct HabitNotificationsScreen: View {
    @Binding var draft: HabitDraft
    @Binding var reminders: [RemindersSection.Row]

    var body: some View {
        Form {
            Section {
                HabitPreview(draft: draft, ringSize: SbuTheme.space12 * 2, symbolFont: SbuTheme.title2)
            }
            .listRowBackground(Color.clear)

            RemindersSection(mode: $draft.reminderMode, rows: $reminders)
                .listRowBackground(SbuTheme.surfaceRaised)

            if draft.canAnnounceHealthMark {
                Section {
                    Picker("Quando si segna da sola", selection: $draft.notificationStyle.announcesHealthMark) {
                        Text("Nessuna")
                            .tag(false)
                        Text("Notifica")
                            .tag(true)
                    }
                    .pickerStyle(.inline)
                    .labelsHidden()
                } header: {
                    Text("Quando si segna da sola")
                } footer: {
                    Text("Ti avvisa quando Salute la segna fatta.")
                }
                .listRowBackground(SbuTheme.surfaceRaised)
            }

            // Only while something notifies: with nothing to say, the two rows would do nothing.
            if draft.showsNotificationStyle {
                Section {
                    Toggle("Sensibili al tempo", isOn: $draft.notificationStyle.isTimeSensitive)
                    Picker("Suono", selection: $draft.notificationStyle.sound) {
                        ForEach(ReminderSound.allCases, id: \.self) { sound in
                            Text(sound.title)
                                .tag(sound)
                        }
                    }
                    .pickerStyle(.navigationLink)
                } footer: {
                    Text("Arrivano anche durante una Full immersion che le consente.")
                }
                .listRowBackground(SbuTheme.surfaceRaised)
            }
        }
        .scrollContentBackground(.hidden)
        .background(SbuTheme.surface)
        .navigationTitle("Notifiche")
        .navigationBarTitleDisplayMode(.inline)
        .onChange(of: draft.notificationStyle.sound) { _, sound in
            ReminderSoundPlayer.play(sound)
        }
        .onChange(of: draft.notificationStyle.announcesHealthMark) { _, announces in
            if announces {
                Task {
                    _ = await ReminderScheduler.requestAuthorization()
                }
            }
        }
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
    @State private var draft: HabitDraft = {
        var draft = HabitDraft(habit: nil, today: LogicalDay(.now))
        draft.linksHealth = true
        draft.reminderMode = .automatic
        return draft
    }()
    @State private var reminders: [RemindersSection.Row] = []

    var body: some View {
        NavigationStack {
            HabitNotificationsScreen(draft: $draft, reminders: $reminders)
        }
        .tint(SbuTheme.accentHabits)
    }
}
