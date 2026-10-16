import SbuKit
import SwiftUI

/// The next dose and the schedule in words: when, at what times, from and until.
struct MedicineScheduleSection: View {
    let medicine: MedicineSnapshot

    @Environment(\.calendar) private var calendar
    @Environment(Clock.self) private var clock

    var body: some View {
        Section("Schema") {
            LabeledContent("Prossima dose") {
                nextDose
            }
            .accessibilityIdentifier("nextDose")
            LabeledContent("Quando") {
                Text(verbatim: ScheduleText.days(of: medicine.schedule, calendar: calendar))
            }
            ForEach(medicine.schedule.effectiveTimes, id: \.self) { time in
                LabeledContent {
                    Text(verbatim: medicine.form.amountText(time.amount))
                } label: {
                    Text(Day(year: 2026, month: 1, day: 1).date(atMinutes: time.minutes, in: calendar), format: .dateTime.hour().minute())
                        .monospacedDigit()
                }
            }
            LabeledContent("Dal") {
                Text(medicine.schedule.start.start(in: calendar), format: .dateTime.day().month(.wide).year())
            }
            if let end = medicine.schedule.end {
                LabeledContent("Al") {
                    Text(end.start(in: calendar), format: .dateTime.day().month(.wide).year())
                }
            }
        }
        .listRowBackground(SbuTheme.surfaceRaised)
    }

    @ViewBuilder
    private var nextDose: some View {
        if medicine.schedule.frequency == .asNeeded {
            Text("Al bisogno")
        } else if let next = NextDose.of(medicine, now: clock.now, calendar: calendar) {
            Text(next.dueDate, format: .dateTime.weekday(.abbreviated).day().hour().minute())
        } else {
            Text("Nessuna")
        }
    }
}

#Preview("Light") {
    MedicineScheduleSectionPreview()
}

#Preview("Dark") {
    MedicineScheduleSectionPreview()
        .preferredColorScheme(.dark)
}

private struct MedicineScheduleSectionPreview: View {
    var body: some View {
        let medicine = MedicineSnapshot(name: "Omega 3", form: .capsule, schedule: Schedule(times: [DoseTime(hour: 8), DoseTime(hour: 20, amount: 2)], start: Day(.now, calendar: .current)))
        List {
            MedicineScheduleSection(medicine: medicine)
        }
        .listStyle(.insetGrouped)
        .scrollContentBackground(.hidden)
        .background(SbuTheme.surface)
        .environment(Clock())
        .tint(SbuTheme.accentMeds)
    }
}
