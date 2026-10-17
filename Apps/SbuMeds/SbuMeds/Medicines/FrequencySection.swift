import SbuKit
import SwiftUI

/// How often: every day, chosen weekdays, every N days, every N hours, in cycles, or as needed.
struct FrequencySection: View {
    @Binding var draft: MedicineDraft

    var body: some View {
        Section {
            Picker("Frequenza", selection: $draft.frequency) {
                ForEach(Frequency.allCases) { frequency in
                    Text(verbatim: ScheduleText.frequencyName(frequency)).tag(frequency)
                }
            }
            .accessibilityIdentifier("frequency")
            switch draft.frequency {
            case .weekdays:
                WeekdayPicker(selection: $draft.weekdays)
            case .everyDays:
                Stepper(value: $draft.everyDays, in: 2...Schedule.maxInterval) {
                    Text("Ogni \(draft.everyDays) giorni")
                }
            case .everyHours:
                Stepper(value: $draft.everyHours, in: 1...12) {
                    Text("Ogni \(draft.everyHours) ore")
                }
            case .cycle:
                Stepper(value: $draft.cycleOn, in: 1...Schedule.maxCycleDays) {
                    Text("Giorni sì: \(draft.cycleOn)")
                }
                Stepper(value: $draft.cycleOff, in: 1...Schedule.maxCycleDays) {
                    Text("Giorni di pausa: \(draft.cycleOff)")
                }
            case .daily, .asNeeded:
                EmptyView()
            }
        } header: {
            Text("Quando")
        } footer: {
            if let footer {
                Text(footer)
            }
        }
    }

    private var footer: LocalizedStringKey? {
        switch draft.frequency {
        case .everyHours: "Dal primo orario, ogni giorno di nuovo."
        case .cycle: "Dal giorno di inizio: per esempio 21 giorni sì e 7 di pausa."
        case .asNeeded: "Nessun promemoria: la segni quando la prendi."
        case .weekdays where draft.weekdays.isEmpty: "Scegli almeno un giorno."
        default: nil
        }
    }
}

#Preview("Light") {
    FrequencySectionPreview()
}

#Preview("Dark") {
    FrequencySectionPreview()
        .preferredColorScheme(.dark)
}

private struct FrequencySectionPreview: View {
    @State private var draft: MedicineDraft = {
        var draft = MedicineDraft(today: Day(.now, calendar: .current), calendar: .current)
        draft.frequency = .weekdays
        return draft
    }()

    var body: some View {
        Form {
            FrequencySection(draft: $draft)
        }
        .environment(\.sbuAccent, .meds)
    }
}
