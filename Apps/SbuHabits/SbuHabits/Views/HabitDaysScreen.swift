import SbuKit
import SwiftUI

/// The form's Giorni screen: which days the habit is expected, or how many in a week or a
/// month, or the one day of an Attività di un giorno.
struct HabitDaysScreen: View {
    @Binding var draft: HabitDraft
    /// The days an Attività di un giorno can take.
    let oneDayRange: PartialRangeFrom<Date>

    var body: some View {
        Form {
            Section {
                Picker("Giorni", selection: $draft.scheduleKind) {
                    ForEach(ScheduleKind.choices(for: draft.kind), id: \.self) { kind in
                        Text(kind.title)
                            .tag(kind)
                    }
                }
                .pickerStyle(.inline)
                .labelsHidden()

                switch draft.scheduleKind {
                case .everyDay:
                    EmptyView()
                case .weekdays:
                    WeekdayPicker(selection: $draft.weekdays)
                case .timesPerWeek:
                    Stepper(value: $draft.timesPerWeek, in: Schedule.timesPerWeekRange) {
                        // The choice above already says "a settimana".
                        Text("\(draft.timesPerWeek) volte")
                    }
                case .timesPerMonth:
                    Stepper(value: $draft.timesPerMonth, in: Schedule.timesPerMonthRange) {
                        Text("\(draft.timesPerMonth) volte")
                    }
                case .oneDay:
                    DatePicker("Giorno", selection: $draft.oneDay, in: oneDayRange, displayedComponents: .date)
                }
            } footer: {
                HabitDaysFooter(scheduleKind: draft.scheduleKind, hasNoWeekdays: draft.weekdays.isEmpty)
            }
            .listRowBackground(SbuTheme.surfaceRaised)
        }
        .scrollContentBackground(.hidden)
        .background(SbuTheme.surface)
        .navigationTitle("Giorni")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview("Light") {
    HabitDaysScreenPreview()
}

#Preview("Dark") {
    HabitDaysScreenPreview()
        .preferredColorScheme(.dark)
}

private struct HabitDaysScreenPreview: View {
    @State private var draft: HabitDraft = {
        var draft = HabitDraft(habit: nil, today: LogicalDay(.now))
        draft.scheduleKind = .weekdays
        return draft
    }()

    var body: some View {
        NavigationStack {
            HabitDaysScreen(draft: $draft, oneDayRange: Date.now...)
        }
        .tint(SbuTheme.accentHabits)
    }
}
