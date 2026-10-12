import SbuKit
import SwiftUI

/// Today's habits in two columns on the field, one column at accessibility text sizes.
struct HabitGrid: View {
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    let model: HabitsModel
    let edit: (Habit) -> Void

    private var columns: [GridItem] {
        Array(repeating: GridItem(.flexible(), spacing: SbuTheme.space3), count: dynamicTypeSize.isAccessibilitySize ? 1 : 2)
    }

    var body: some View {
        // Centered in the free space while it fits, scrolling once it does not.
        GeometryReader { proxy in
            ScrollView {
                grid
                    .frame(minHeight: proxy.size.height)
            }
            .scrollBounceBehavior(.basedOnSize)
        }
    }

    private var grid: some View {
        LazyVGrid(columns: columns, spacing: SbuTheme.space6) {
            ForEach(model.todayHabits) { habit in
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
