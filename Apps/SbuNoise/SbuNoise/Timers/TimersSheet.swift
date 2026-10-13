import SbuKit
import SwiftUI

/// Alarms and timers, opened from the bottom bar as in the original: each one on or off, tap to
/// change it, swipe to delete, Aggiungi for a new one of either.
struct TimersSheet: View {
    let timers: TimersModel
    let alarms: AlarmsModel
    let sounds: [Sound]

    @Environment(\.dismiss) private var dismiss
    @State private var editingTimer: SoundTimer?
    @State private var editingAlarm: SoundAlarm?
    /// A swipe to delete waits for this confirmation.
    @State private var deleting: Deletion?

    var body: some View {
        NavigationStack {
            List {
                if !alarms.alarms.isEmpty {
                    Section {
                        ForEach(alarms.alarms) { alarm in
                            AlarmRow(alarm: alarm, soundName: soundName(alarm), isOn: isOn(alarm)) { editingAlarm = alarm }
                        }
                        .onDelete { offsets in deleting = offsets.first.map { .alarm(alarms.alarms[$0].id) } }
                        ForEach(listWarnings, id: \.self) { warning in
                            AlarmWarningRow(warning: warning)
                        }
                    } header: {
                        Text("Sveglie")
                    } footer: {
                        Text(alarms.backup.kind.footer)
                    }
                }
                if !timers.timers.isEmpty {
                    Section("Timer") {
                        ForEach(timers.timers) { timer in
                            TimerRow(timer: timer, isOn: isOn(timer)) { editingTimer = timer }
                        }
                        .onDelete { offsets in deleting = offsets.first.map { .timer(timers.timers[$0].id) } }
                    }
                }
            }
            .overlay {
                if timers.timers.isEmpty && alarms.alarms.isEmpty {
                    ContentUnavailableView("Nessun timer né sveglia", systemImage: "timer", description: Text("Aggiungi un timer per fermare il suono, o una sveglia per il mattino."))
                }
            }
            .navigationTitle("Timer e sveglie")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Fine") { dismiss() }
                }
                ToolbarItem(placement: .primaryAction) {
                    Menu("Aggiungi", systemImage: "plus") {
                        Button("Nuovo timer", systemImage: "timer") { editingTimer = SoundTimer() }
                        Button("Nuova sveglia", systemImage: "alarm") { editingAlarm = SoundAlarm() }
                    }
                }
            }
            .confirmationDialog(deletionTitle, isPresented: isConfirmingDeletion, titleVisibility: .visible) {
                Button(deletionTitle, role: .destructive, action: confirmDeletion)
            }
            .sheet(item: $editingTimer) { timer in
                let isNew = !timers.timers.contains { $0.id == timer.id }
                TimerEditor(timer: timer, isNew: isNew, onSave: timers.save) {
                    timers.delete(timer.id)
                }
            }
            .sheet(item: $editingAlarm) { alarm in
                let isNew = !alarms.alarms.contains { $0.id == alarm.id }
                AlarmEditor(alarm: alarm, isNew: isNew, sounds: sounds, backupKind: alarms.backup.kind, warnings: warnings, onSave: alarms.save) {
                    alarms.delete(alarm.id)
                }
            }
        }
    }

    /// The warnings for the next alarm, under the list.
    private var listWarnings: [AlarmWarning] {
        alarms.next.map { warnings($0.alarm) } ?? []
    }

    private func warnings(_ alarm: SoundAlarm) -> [AlarmWarning] {
        AlarmWarning.list(permission: alarms.permission, kind: alarms.backup.kind, alarmDate: alarm.fireDate(after: .now), timerStop: timers.next?.date)
    }

    private func soundName(_ alarm: SoundAlarm) -> LocalizedStringResource {
        (Sound.alarmTones + sounds).first { $0.id == alarm.soundID }?.name ?? Sound.alarmTones[0].name
    }

    private var deletionTitle: LocalizedStringKey {
        if case .alarm = deleting { "Elimina sveglia" } else { "Elimina timer" }
    }

    private var isConfirmingDeletion: Binding<Bool> {
        Binding { deleting != nil } set: { if !$0 { deleting = nil } }
    }

    private func confirmDeletion() {
        switch deleting {
        case .timer(let id): timers.delete(id)
        case .alarm(let id): alarms.delete(id)
        case nil: break
        }
        deleting = nil
    }

    /// Turning a timer on starts its countdown, so the switch goes through the model.
    private func isOn(_ timer: SoundTimer) -> Binding<Bool> {
        Binding { timer.isOn } set: { timers.setOn($0, for: timer.id) }
    }

    /// Turning an alarm on arms it from now, so the switch goes through the model.
    private func isOn(_ alarm: SoundAlarm) -> Binding<Bool> {
        Binding { alarm.isOn } set: { alarms.setOn($0, for: alarm.id) }
    }
}

#Preview("Light") {
    let player = PlayerModel()
    TimersSheet(timers: .preview, alarms: .preview(player: player), sounds: player.sounds)
        .tint(SbuTheme.accentNoise)
}

#Preview("Dark") {
    let player = PlayerModel()
    TimersSheet(timers: .preview, alarms: .preview(player: player), sounds: player.sounds)
        .tint(SbuTheme.accentNoise)
        .preferredColorScheme(.dark)
}
