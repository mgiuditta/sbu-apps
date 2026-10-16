import SbuKit
import SwiftUI

/// The times of the day, each with how much: one tablet in the morning, two in the evening.
/// Every N hours asks for the first time only; as needed, only how much.
struct DoseTimesSection: View {
    @Binding var draft: MedicineDraft

    @Environment(\.calendar) private var calendar

    var body: some View {
        Section {
            switch draft.frequency {
            case .asNeeded:
                AmountStepper(amount: $draft.asNeededAmount, form: draft.form)
            case .everyHours:
                if !draft.times.isEmpty {
                    DatePicker("Primo orario", selection: time(at: 0), displayedComponents: .hourAndMinute)
                    AmountStepper(amount: amount(at: 0), form: draft.form)
                }
                Text(verbatim: ScheduleText.times(of: draft.schedule, calendar: calendar))
                    .font(SbuTheme.subheadline)
                    .foregroundStyle(SbuTheme.inkMuted)
            default:
                ForEach(draft.times.indices, id: \.self) { index in
                    VStack(alignment: .leading, spacing: SbuTheme.space2) {
                        DatePicker("Orario", selection: time(at: index), displayedComponents: .hourAndMinute)
                            .accessibilityIdentifier("doseTime")
                        AmountStepper(amount: amount(at: index), form: draft.form)
                    }
                    .deleteDisabled(draft.times.count < 2)
                }
                .onDelete(perform: delete)
                if draft.times.count < MedicineDraft.maxTimes {
                    Button("Aggiungi orario", systemImage: "plus", action: addTime)
                        .accessibilityIdentifier("addTime")
                }
            }
        } header: {
            Text(draft.frequency == .asNeeded ? "Dose" : "Orari e dose")
        } footer: {
            if draft.frequency != .asNeeded, draft.frequency != .everyHours {
                Text("Gli orari restano questi anche se cambi fuso orario.")
            }
        }
    }

    private func time(at index: Int) -> Binding<Date> {
        let day = Day(year: 2026, month: 1, day: 1)
        return Binding {
            day.date(atMinutes: draft.times.indices.contains(index) ? draft.times[index].minutes : 8 * 60, in: calendar)
        } set: { date in
            guard draft.times.indices.contains(index) else { return }
            let parts = calendar.dateComponents([.hour, .minute], from: date)
            draft.times[index] = DoseTime(hour: parts.hour ?? 0, minute: parts.minute ?? 0, amount: draft.times[index].amount)
        }
    }

    private func amount(at index: Int) -> Binding<Double> {
        Binding {
            draft.times.indices.contains(index) ? draft.times[index].amount : 1
        } set: { amount in
            guard draft.times.indices.contains(index) else { return }
            draft.times[index] = DoseTime(minutes: draft.times[index].minutes, amount: amount)
        }
    }

    private func delete(at offsets: IndexSet) {
        for index in offsets.sorted(by: >) {
            draft.removeTime(at: index)
        }
    }

    private func addTime() {
        draft.addTime()
    }
}

#Preview("Light") {
    DoseTimesSectionPreview()
}

#Preview("Dark") {
    DoseTimesSectionPreview()
        .preferredColorScheme(.dark)
}

private struct DoseTimesSectionPreview: View {
    @State private var draft: MedicineDraft = {
        var draft = MedicineDraft(today: Day(.now, calendar: .current), calendar: .current)
        draft.times = [DoseTime(hour: 8), DoseTime(hour: 20, amount: 2)]
        return draft
    }()

    var body: some View {
        Form {
            DoseTimesSection(draft: $draft)
        }
        .tint(SbuTheme.accentMeds)
    }
}
