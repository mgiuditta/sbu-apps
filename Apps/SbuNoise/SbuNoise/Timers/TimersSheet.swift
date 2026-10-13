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

    var body: some View {
        NavigationStack {
            List {
                if !alarms.alarms.isEmpty {
                    Section {
                        ForEach(alarms.alarms) { alarm in
                            AlarmRow(alarm: alarm, soundName: soundName(alarm), isOn: isOn(alarm)) { editingAlarm = alarm }
                        }
                        .onDelete(perform: deleteAlarms)
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
                        .onDelete { timers.delete(at: $0) }
                    }
                }
            }
            .overlay {
                if timers.timers.isEmpty && alarms.alarms.isEmpty {
                    ContentUnavailableView("Nessun timer", systemImage: "timer", description: Text("Aggiungi un timer per fermare il suono, o una sveglia per svegliarti."))
                }
            }
            .navigationTitle("Timer")
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

    private func deleteAlarms(at offsets: IndexSet) {
        for index in offsets { alarms.delete(alarms.alarms[index].id) }
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
