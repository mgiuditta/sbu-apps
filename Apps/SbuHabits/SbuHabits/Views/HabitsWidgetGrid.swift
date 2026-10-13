import SbuKit
import SwiftUI

/// The widget's grid, shared with the app so tests can draw it. Cells keep the size of a full
/// grid of `columns` by `rows`, whatever the count; rows sit centered, a short last row too.
/// Each ring is drawn as on the home, its title in uppercase after the heart or the ⊘.
/// A "+N" cell stands for habits that do not fit. Tapping a ring marks it once; tapping anywhere
/// else, "+N" included, opens the app.
struct HabitsWidgetGrid: View {
    let slots: WidgetSlots
    let progress: [Habit.ID: HabitProgress]
    /// Each habit's Serie, for VoiceOver: the grid's rings are too small to show it, as in Streaks.
    var streaks: [Habit.ID: Int] = [:]
    let columns: Int
    let rows: Int
    let showsTitles: Bool

    private var cells: [Cell] {
        slots.shown.map(Cell.habit) + (slots.overflow > 0 ? [.more(slots.overflow)] : [])
    }

    var body: some View {
        let cells = cells
        let spacing = SbuTheme.space2
        GeometryReader { proxy in
            let size = CGSize(
                width: (proxy.size.width - spacing * CGFloat(columns - 1)) / CGFloat(columns),
                height: (proxy.size.height - spacing * CGFloat(rows - 1)) / CGFloat(rows)
            )
            VStack(spacing: spacing) {
                ForEach(Array(stride(from: 0, to: cells.count, by: columns)), id: \.self) { start in
                    HStack(spacing: spacing) {
                        ForEach(start..<min(start + columns, cells.count), id: \.self) { index in
                            cellView(cells[index])
                                .frame(width: size.width, height: size.height)
                        }
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }

    @ViewBuilder
    private func cellView(_ cell: Cell) -> some View {
        switch cell {
        case .habit(let habit):
            if let progress = progress[habit.id] {
                WidgetRingButton(habit: habit, progress: progress, streak: streaks[habit.id] ?? 0, showsCaption: showsTitles)
            }
        case .more(let count):
            WidgetMoreCell(count: count, showsTitle: showsTitles)
        }
    }

    private enum Cell {
        case habit(Habit)
        case more(Int)
    }
}

private struct WidgetMoreCell: View {
    let count: Int
    let showsTitle: Bool

    var body: some View {
        VStack(spacing: SbuTheme.space1) {
            Circle()
                .strokeBorder(SbuTheme.line, lineWidth: SbuTheme.space1)
                .overlay {
                    Text(verbatim: "+\(count)")
                        .font(SbuTheme.headline)
                        .monospacedDigit()
                        .foregroundStyle(SbuTheme.ink)
                }
                .aspectRatio(1, contentMode: .fit)
                .frame(maxWidth: .infinity, maxHeight: .infinity)

            if showsTitle {
                // Keeps the ring level with its neighbours.
                SlotCaption(title: Text(verbatim: " "), maxLines: 1, font: SbuTheme.caption)
                    .dynamicTypeSize(...DynamicTypeSize.xLarge)
                    .hidden()
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(Text("Altre \(count) abitudini"))
    }
}

#Preview("Light") {
    HabitsWidgetGridPreview()
}

#Preview("Dark") {
    HabitsWidgetGridPreview()
        .preferredColorScheme(.dark)
}

private struct HabitsWidgetGridPreview: View {
    private let today = LogicalDay(.now)

    /// An Abitudine da evitare given in `times` times today.
    private func avoided(_ title: String, symbol: String, limit: Int, times: Int) -> Habit {
        var habit = Habit(title: title, symbol: symbol, limit: limit, createdOn: today)
        habit.log[today] = times
        return habit
    }

    var body: some View {
        let habits = [avoided("Caffè", symbol: "cup.and.saucer", limit: 2, times: 1), avoided("Non fumare", symbol: "lungs", limit: 0, times: 1)]
            + (0..<8).map { Habit(title: "Abitudine \($0 + 1)", symbol: "book", createdOn: today) }
        let progress = Dictionary(uniqueKeysWithValues: habits.map { ($0.id, HabitProgress(of: $0, today: today, firstWeekday: 2)) })
        HabitsWidgetGrid(slots: WidgetSlots(habits, progress: progress, capacity: 8), progress: progress, columns: 4, rows: 2, showsTitles: true)
            .frame(width: 338, height: 158)
            .padding(SbuTheme.space4)
            .background(SbuTheme.surface)
            .tint(SbuTheme.accentHabits)
    }
}
