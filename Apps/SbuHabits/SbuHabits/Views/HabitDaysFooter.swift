import SwiftUI

/// Under the Giorni picker: what a counted schedule or an Attività di un giorno means, and that
/// a week needs at least one day.
struct HabitDaysFooter: View {
    let scheduleKind: ScheduleKind
    let hasNoWeekdays: Bool

    var body: some View {
        switch scheduleKind {
        case .weekdays where hasNoWeekdays:
            Text("Scegli almeno un giorno.")
        case .timesPerWeek, .timesPerMonth:
            Text("Nei giorni che vuoi: la segni una volta al giorno.")
        case .oneDay:
            Text("Compare nella griglia solo quel giorno.")
        case .everyDay, .weekdays:
            EmptyView()
        }
    }
}

#Preview("Light") {
    Form {
        Section {} footer: {
            HabitDaysFooter(scheduleKind: .oneDay, hasNoWeekdays: false)
        }
    }
}

#Preview("Dark") {
    Form {
        Section {} footer: {
            HabitDaysFooter(scheduleKind: .weekdays, hasNoWeekdays: true)
        }
    }
    .preferredColorScheme(.dark)
}
