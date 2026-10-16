import SbuKit
import SwiftUI

/// The figure of the app: doses still to take that day, late ones included, closed by the full stop.
struct TodayFigure: View {
    let plan: DayPlan
    let isToday: Bool

    @Environment(\.calendar) private var calendar

    var body: some View {
        SbuStat(label, value: plan.toTakeCount, format: .number, context: context)
            .accessibilityIdentifier("todayFigure")
    }

    private var label: LocalizedStringKey {
        isToday ? "Da prendere oggi" : "Da prendere \(plan.day.start(in: calendar).formatted(.dateTime.weekday(.wide).day().month(.wide)))"
    }

    private var context: LocalizedStringKey {
        if plan.scheduledCount == 0 { return "Nessuna dose prevista" }
        if plan.lateCount > 0 { return "Prese \(plan.takenCount) su \(plan.scheduledCount) · \(plan.lateCount) in ritardo" }
        return "Prese \(plan.takenCount) su \(plan.scheduledCount)"
    }
}

#Preview("Light") {
    TodayFigurePreview()
}

#Preview("Dark") {
    TodayFigurePreview()
        .preferredColorScheme(.dark)
}

private struct TodayFigurePreview: View {
    var body: some View {
        let medicine = MedicineSnapshot(name: "Ramipril", schedule: Schedule(times: [DoseTime(hour: 8), DoseTime(hour: 20)], start: Day(.now, calendar: .current)))
        VStack(spacing: SbuTheme.space4) {
            TodayFigure(plan: DayPlan([medicine], day: Day(.now, calendar: .current), now: .now, calendar: .current), isToday: true)
            TodayFigure(plan: DayPlan([], day: Day(.now, calendar: .current), now: .now, calendar: .current), isToday: false)
        }
        .padding(SbuTheme.space4)
        .frame(maxHeight: .infinity)
        .background(SbuTheme.surface)
        .tint(SbuTheme.accentMeds)
    }
}
