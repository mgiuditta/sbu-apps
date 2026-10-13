import SbuKit
import SwiftUI

/// Adds or changes an alarm, laid out like the timer editor: the time on a wheel, then repeat,
/// sound, fade in and snooze, the fixed line on when it rings, and any warning.
struct AlarmEditor: View {
    let isNew: Bool
    let sounds: [Sound]
    let backupKind: AlarmBackupKind
    /// The warnings for the alarm as edited.
    let warnings: (SoundAlarm) -> [AlarmWarning]
    let onSave: (SoundAlarm) -> Void
    let onDelete: () -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var alarm: SoundAlarm
    @State private var time: Date

    init(
        alarm: SoundAlarm,
        isNew: Bool,
        sounds: [Sound],
        backupKind: AlarmBackupKind,
        warnings: @escaping (SoundAlarm) -> [AlarmWarning],
        onSave: @escaping (SoundAlarm) -> Void,
        onDelete: @escaping () -> Void
    ) {
        self.isNew = isNew
        self.sounds = sounds
        self.backupKind = backupKind
        self.warnings = warnings
        self.onSave = onSave
        self.onDelete = onDelete
        _alarm = State(initialValue: alarm)
        _time = State(initialValue: Calendar.current.date(bySettingHour: alarm.hour, minute: alarm.minute, second: 0, of: .now) ?? .now)
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    DatePicker("Ora", selection: $time, displayedComponents: .hourAndMinute)
                        .datePickerStyle(.wheel)
                        .labelsHidden()
                        .frame(maxWidth: .infinity)
                }

                Section {
                    NavigationLink {
                        WeekdaysPicker(selection: $alarm.weekdays)
                    } label: {
                        LabeledContent("Ripeti", value: edited.repeatSummary())
                    }
                    NavigationLink {
                        AlarmSoundPicker(sounds: sounds, selection: $alarm.soundID)
                    } label: {
                        LabeledContent("Suono") {
                            Text(soundName)
                        }
                    }
                    Picker("Dissolvenza in entrata", selection: $alarm.fadeIn) {
                        ForEach(AlarmFadeIn.allCases) { fade in
                            Text(fade.label).tag(fade)
                        }
                    }
                    .pickerStyle(.navigationLink)
                    Picker("Rimanda", selection: $alarm.snoozeMinutes) {
                        ForEach(SoundAlarm.snoozeChoices, id: \.self) { minutes in
                            Text(SoundAlarm.snoozeLabel(minutes)).tag(minutes)
                        }
                    }
                    .pickerStyle(.navigationLink)
                } footer: {
                    Text(backupKind.footer)
                }

                let warnings = warnings(edited)
                if !warnings.isEmpty {
                    Section {
                        ForEach(warnings, id: \.self) { warning in
                            AlarmWarningRow(warning: warning)
                        }
                    }
                }

                if !isNew {
                    Section {
                        SbuButton("Elimina sveglia", kind: .destructive) {
                            onDelete()
                            dismiss()
                        }
                    }
                }
            }
            .navigationTitle(isNew ? "Nuova sveglia" : "Modifica sveglia")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Annulla") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Salva", action: save)
                }
            }
        }
    }

    /// The alarm as it will be saved, with the time from the wheel.
    private var edited: SoundAlarm {
        var alarm = alarm
        let parts = Calendar.current.dateComponents([.hour, .minute], from: time)
        alarm.hour = parts.hour ?? 0
        alarm.minute = parts.minute ?? 0
        return alarm.armed(at: .now)
    }

    private var soundName: LocalizedStringResource {
        (Sound.alarmTones + sounds).first { $0.id == alarm.soundID }?.name ?? Sound.alarmTones[0].name
    }

    private func save() {
        onSave(edited)
        dismiss()
    }
}

#Preview("Light") {
    AlarmEditor(alarm: SoundAlarm(), isNew: true, sounds: Sound.catalog, backupKind: .notifications, warnings: { _ in [] }, onSave: { _ in }, onDelete: {})
        .tint(SbuTheme.accentNoise)
}

#Preview("Dark") {
    AlarmEditor(alarm: SoundAlarm(weekdays: [2, 3, 4, 5, 6]), isNew: false, sounds: Sound.catalog, backupKind: .systemAlarm, warnings: { _ in [.soundStopsBefore(.systemAlarm)] }, onSave: { _ in }, onDelete: {})
        .tint(SbuTheme.accentNoise)
        .preferredColorScheme(.dark)
}
