import SbuKit
import SwiftUI

/// The figure zone of today, on the paper's grid: the title and its cartiglio, then the doses
/// still to take that day, late ones included. The full stop waits while doses remain and is set
/// once the day's doses are all done. With no medicine yet, the empty state takes the figure's place.
struct TodayFigure: View {
    let plan: DayPlan
    let isToday: Bool
    let hasMedicines: Bool
    @Binding var isClosing: Bool
    let addMedicine: () -> Void

    @Environment(\.calendar) private var calendar

    var body: some View {
        VStack(alignment: .leading, spacing: SbuTheme.gridCell) {
            // In whole cells, with a cell of padding and a cell of spacing: the figure starts on a grid line.
            SbuScreenTitle("Da prendere", cartiglio: cartiglio)
                .wholeGridCells()
            if hasMedicines {
                SbuFigure(
                    value: plan.toTakeCount.formatted(),
                    fullStop: fullStop,
                    context: Text(context),
                    accessibilityLabel: Text("\(Text(label)): \(plan.toTakeCount). \(Text(context))")
                )
                .sbuClosure($isClosing, word: "Presa")
                .accessibilityIdentifier("todayFigure")
            } else {
                SbuEmpty(sentence: "Aggiungi un farmaco con i suoi orari: qui trovi le dosi del giorno.") {
                    Button("Aggiungi farmaco", action: addMedicine)
                        .accessibilityIdentifier("addFirstMedicine")
                }
            }
        }
        .padding(.horizontal, SbuTheme.space4)
        .padding(.vertical, SbuTheme.gridCell)
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    /// Set once every dose of the day is taken, skipped or past; waiting while some remain or none is due.
    private var fullStop: SbuFullStop.State {
        plan.scheduledCount > 0 && plan.toTakeCount == 0 ? .set : .waiting
    }

    /// "Sbu · Farmaci · sab 17 ott", with the day shown.
    private var cartiglio: String {
        let day = plan.day.start(in: calendar).formatted(.dateTime.weekday(.abbreviated).day().month(.abbreviated))
        return ["Sbu", String(localized: "Farmaci"), day].joined(separator: " · ")
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
    @State private var isClosing = false

    var body: some View {
        let medicine = MedicineSnapshot(name: "Ramipril", schedule: Schedule(times: [DoseTime(hour: 8), DoseTime(hour: 20)], start: Day(.now, calendar: .current)))
        ScrollView {
            VStack(spacing: 0) {
                TodayFigure(plan: DayPlan([medicine], day: Day(.now, calendar: .current), now: .now, calendar: .current),
                            isToday: true, hasMedicines: true, isClosing: $isClosing) {}
                TodayFigure(plan: DayPlan([], day: Day(.now, calendar: .current), now: .now, calendar: .current),
                            isToday: true, hasMedicines: false, isClosing: $isClosing) {}
            }
            .sbuPaper(grid: true)
        }
        .environment(\.sbuAccent, .meds)
    }
}
