import SbuKit
import SwiftUI

/// Adds or changes a timer, laid out like the original: event, fade and repeat, then
/// Durata | Ora and the wheel.
struct TimerEditor: View {
    let isNew: Bool
    let onSave: (SoundTimer) -> Void
    let onDelete: () -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var timer: SoundTimer
    @State private var isClock: Bool
    @State private var hours: Int
    @State private var minutes: Int
    @State private var time: Date

    init(timer: SoundTimer, isNew: Bool, onSave: @escaping (SoundTimer) -> Void, onDelete: @escaping () -> Void) {
        self.isNew = isNew
        self.onSave = onSave
        self.onDelete = onDelete
        _timer = State(initialValue: timer)
        switch timer.trigger {
        case .duration(let total):
            _isClock = State(initialValue: false)
            _hours = State(initialValue: total / 60)
            _minutes = State(initialValue: total % 60)
            _time = State(initialValue: .now)
        case .clock(let hour, let minute):
            _isClock = State(initialValue: true)
            _hours = State(initialValue: 0)
            _minutes = State(initialValue: 30)
            _time = State(initialValue: Calendar.current.date(bySettingHour: hour, minute: minute, second: 0, of: .now) ?? .now)
        }
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    LabeledContent("Evento", value: String(localized: "Ferma il suono"))
                    Picker("Dissolvenza", selection: $timer.fade) {
                        ForEach(SoundTimerFade.allCases) { fade in
                            Text(fade.label).tag(fade)
                        }
                    }
                    .pickerStyle(.navigationLink)
                    repeatRow
                }

                Section {
                    Picker("Tipo di timer", selection: $isClock) {
                        Text("Durata").tag(false)
                        Text("Ora").tag(true)
                    }
                    .pickerStyle(.segmented)
                    .labelsHidden()

                    if isClock {
                        DatePicker("Ora", selection: $time, displayedComponents: .hourAndMinute)
                            .datePickerStyle(.wheel)
                            .labelsHidden()
                            .frame(maxWidth: .infinity)
                    } else {
                        DurationWheel(hours: $hours, minutes: $minutes)
                    }
                }

                if !isNew {
                    Section {
                        SbuButton("Elimina timer", kind: .destructive) {
                            onDelete()
                            dismiss()
                        }
                    }
                }
            }
            .navigationTitle(isNew ? "Nuovo timer" : "Modifica timer")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Annulla") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Salva") {
                        onSave(edited)
                        dismiss()
                    }
                    .disabled(!isClock && hours == 0 && minutes == 0)
                }
            }
        }
    }

    @ViewBuilder private var repeatRow: some View {
        if isClock {
            NavigationLink {
                WeekdaysPicker(selection: $timer.weekdays)
            } label: {
                LabeledContent("Ripeti", value: edited.repeatSummary())
            }
        } else {
            Picker("Ripeti", selection: $timer.repeatsAlways) {
                Text("Mai").tag(false)
                Text("Sempre").tag(true)
            }
            .pickerStyle(.navigationLink)
        }
    }

    /// The timer as it will be saved: turned on, with the trigger from the wheel.
    private var edited: SoundTimer {
        var timer = timer
        timer.isOn = true
        if isClock {
            let parts = Calendar.current.dateComponents([.hour, .minute], from: time)
            timer.trigger = .clock(hour: parts.hour ?? 0, minute: parts.minute ?? 0)
        } else {
            timer.trigger = .duration(minutes: hours * 60 + minutes)
        }
        return timer
    }
}

#Preview("Light") {
    TimerEditor(timer: SoundTimer(), isNew: true) { _ in } onDelete: {}
        .tint(SbuTheme.accentNoise)
}

#Preview("Dark") {
    TimerEditor(timer: SoundTimer(trigger: .clock(hour: 23, minute: 30), weekdays: [2, 3, 4, 5, 6]), isNew: false) { _ in } onDelete: {}
        .tint(SbuTheme.accentNoise)
        .preferredColorScheme(.dark)
}
