import SbuKit
import SwiftUI

/// Today's habits on the field: two columns for a few, three for more, one at accessibility
/// text sizes. A short last row sits centered; past the screen, the grid scrolls.
struct HabitGrid: View {
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    let model: HabitsModel
    let edit: (Habit) -> Void

    var body: some View {
        let habits = model.todayHabits
        let columns = dynamicTypeSize.isAccessibilitySize ? 1 : habits.count > 4 ? 3 : 2
        // Centered in the free space while it fits, scrolling once it does not.
        GeometryReader { proxy in
            let cellWidth = (proxy.size.width - SbuTheme.space3 * CGFloat(columns - 1)) / CGFloat(columns)
            ScrollView {
                LazyVStack(spacing: SbuTheme.space6) {
                    ForEach(rows(of: habits, columns: columns), id: \.first?.id) { row in
                        HStack(alignment: .top, spacing: SbuTheme.space3) {
                            ForEach(row) { habit in
                                cell(for: habit)
                                    .frame(width: cellWidth)
                            }
                        }
                    }
                }
                .frame(maxWidth: .infinity, minHeight: proxy.size.height)
            }
            .scrollBounceBehavior(.basedOnSize)
            .scrollIndicatorsFlash(onAppear: true)
        }
    }

    private func rows(of habits: [Habit], columns: Int) -> [[Habit]] {
        stride(from: 0, to: habits.count, by: columns).map { Array(habits[$0..<min($0 + columns, habits.count)]) }
    }

    private func cell(for habit: Habit) -> HabitCell {
        HabitCell(
            habit: habit,
            progress: model.progress(of: habit),
            streak: model.streak(of: habit),
            markDone: { model.markDone(habit) },
            undoLast: { model.undoLast(habit) },
            toggleSkip: { model.toggleSkip(habit) },
            edit: { edit(habit) }
        )
    }
}

#Preview("Light") {
    HabitGrid(model: .preview) { _ in }
        .padding(SbuTheme.space4)
        .background(SbuTheme.fieldHabits)
        .environment(\.colorScheme, .dark)
        .tint(SbuTheme.accentHabits)
}

#Preview("Dark") {
    HabitGrid(model: .preview) { _ in }
        .padding(SbuTheme.space4)
        .background(SbuTheme.fieldHabits)
        .environment(\.colorScheme, .dark)
        .tint(SbuTheme.accentHabits)
        .preferredColorScheme(.dark)
}
